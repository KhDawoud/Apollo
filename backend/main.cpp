//Backend
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <boost/asio/dispatch.hpp>
#include <boost/asio/strand.hpp>
#include <boost/config.hpp>
#include <boost/json/src.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/beast/ssl.hpp>
#include <openssl/err.h>
#include <pqxx/pqxx>
#include <iostream>
#include <string>
#include <fstream>
#include <cstdlib>
#include <memory>
#include <thread>
#include <vector>
#include <filesystem>
#include <cstdlib>

namespace beast = boost::beast;
namespace http = beast::http;
namespace net = boost::asio;
using tcp = boost::asio::ip::tcp;

// so I don't push API key to github
void load_env(const std::string &file_path = ".env")
{
    std::ifstream file(file_path);
    if (!file.is_open())
        return;

    std::string line;
    while (std::getline(file, line))
    {
        if (line.empty() || line[0] == '#')
            continue;
        auto delimiter_pos = line.find('=');
        if (delimiter_pos != std::string::npos)
        {
            std::string key = line.substr(0, delimiter_pos);
            std::string value = line.substr(delimiter_pos + 1);
            if (value.size() >= 2 && value.front() == '"' && value.back() == '"')
            {
                value = value.substr(1, value.size() - 2);
            }
#ifdef _WIN32
            _putenv_s(key.c_str(), value.c_str());
#else
            setenv(key.c_str(), value.c_str(), 1);
#endif
        }
    }
}

void handle_ask_ai(const http::request<http::string_body> &req, http::response<http::string_body> &res)
{
    boost::json::value parsed_body = boost::json::parse(req.body());
    std::string problem_desc = parsed_body.at("problem_description").as_string().c_str();
    std::string user_code = parsed_body.at("code").as_string().c_str();

    const char *api_key = std::getenv("GROQ_API_KEY");
    if (!api_key)
    {
        res.result(http::status::internal_server_error);
        res.body() = R"({"status": "error", "message": "API key not added"})";
        return;
    }

    try
    {
        // this part is mostly AI since I had no clue how to use the groq API without a wrapper library like in python
        namespace ssl = boost::asio::ssl;
        net::io_context ioc;
        ssl::context ctx(ssl::context::tlsv12_client);
        ctx.set_default_verify_paths();

        tcp::resolver resolver(ioc);
        beast::ssl_stream<beast::tcp_stream> stream(ioc, ctx);

        // Set SNI Hostname
        if (!SSL_set_tlsext_host_name(stream.native_handle(), "api.groq.com"))
        {
            beast::error_code ec{static_cast<int>(::ERR_get_error()), net::error::get_ssl_category()};
            throw beast::system_error{ec};
        }

        // Resolve and connect
        auto const results = resolver.resolve("api.groq.com", "443");
        beast::get_lowest_layer(stream).connect(results);
        stream.handshake(ssl::stream_base::client);

        // Construct the HTTP POST request to Groq's OpenAI-compatible endpoint
        http::request<http::string_body> groq_req{http::verb::post, "/openai/v1/chat/completions", 11};
        groq_req.set(http::field::host, "api.groq.com");
        groq_req.set(http::field::authorization, std::string("Bearer ") + api_key);
        groq_req.set(http::field::content_type, "application/json");

        // Build the JSON Payload
        boost::json::object body;
        body["model"] = "llama-3.3-70b-versatile";

        boost::json::array messages;

        boost::json::object sys_msg;
        sys_msg["role"] = "system";
        sys_msg["content"] = "You are a helpful coding assistant. Given a problem description and the user's code, give a small hint that nudges them in the right direction without directly giving them the answer or giving them step by step instructions. Keep your response strictly under 100 words.";
        messages.push_back(sys_msg);

        boost::json::object usr_msg;
        usr_msg["role"] = "user";
        usr_msg["content"] = "Problem:\n" + problem_desc + "\n\nUser Code:\n" + user_code;
        messages.push_back(usr_msg);

        body["messages"] = messages;
        groq_req.body() = boost::json::serialize(body);
        groq_req.prepare_payload();

        // Send request and read response
        http::write(stream, groq_req);
        beast::flat_buffer buffer;
        http::response<http::string_body> groq_res;
        http::read(stream, buffer, groq_res);

        // Gracefully close the stream
        beast::error_code ec;
        stream.shutdown(ec);
        if (ec == net::error::eof || ec == ssl::error::stream_truncated)
        {
            ec = {}; // Expected errors on connection close
        }

        // Parse Groq's response and send it back to the client
        if (groq_res.result() == http::status::ok)
        {
            boost::json::value groq_parsed = boost::json::parse(groq_res.body());
            std::string ai_response = groq_parsed.at("choices").as_array()[0].as_object().at("message").as_object().at("content").as_string().c_str();

            boost::json::object response_json;
            response_json["status"] = "success";
            response_json["hint"] = ai_response;

            res.result(http::status::ok);
            res.body() = boost::json::serialize(response_json);
        }
        else
        {
            res.result(http::status::bad_gateway);
            res.body() = R"({"status": "error", "message": "Failed to fetch response from AI"})";
            std::cerr << "Groq API Error: " << groq_res.body() << "\n";
        }
    }
    catch (const std::exception &e)
    {
        res.result(http::status::internal_server_error);
        res.body() = R"({"status": "error", "message": "Error communicating with AI service"})";
        std::cerr << "SSL/Network Error: " << e.what() << "\n";
    }
}

void handle_login(const http::request<http::string_body> &req, http::response<http::string_body> &res, const char *db_url)
{
    boost::json::value parsed_body = boost::json::parse(req.body());
    std::string identifier = parsed_body.at("identifier").as_string().c_str();
    std::string raw_password = parsed_body.at("password").as_string().c_str();

    pqxx::connection C(db_url);
    pqxx::nontransaction N(C);

    std::string query =
        "SELECT username, total_xp, daily_streak FROM users WHERE (email = " + N.quote(identifier) +
        " OR username = " + N.quote(identifier) + ") " +
        "AND password_hash = crypt(" + N.quote(raw_password) + ", password_hash);";

    pqxx::result R = N.exec(query);

    if (!R.empty())
    {
        boost::json::object response_json;
        response_json["status"] = "success";
        response_json["username"] = R[0]["username"].as<std::string>();
        response_json["total_xp"] = R[0]["total_xp"].as<int>();
        response_json["daily_streak"] = R[0]["daily_streak"].as<int>();

        res.result(http::status::ok);
        res.body() = boost::json::serialize(response_json);
    }
    else
    {
        res.result(http::status::unauthorized);
        res.body() = R"({"status": "error", "message": "Invalid credentials"})";
    }
}

void handle_signup(const http::request<http::string_body> &req, http::response<http::string_body> &res, const char *db_url)
{
    boost::json::value parsed_body = boost::json::parse(req.body());
    std::string email = parsed_body.at("email").as_string().c_str();
    std::string username = parsed_body.at("username").as_string().c_str();
    std::string raw_password = parsed_body.at("password").as_string().c_str();

    pqxx::connection C(db_url);
    pqxx::work W(C);

    std::string query =
        "INSERT INTO users (email, username, password_hash) VALUES (" +
        W.quote(email) + ", " +
        W.quote(username) + ", " +
        "crypt(" + W.quote(raw_password) + ", gen_salt('bf'))) " +
        "RETURNING username, total_xp, daily_streak;";

    pqxx::result R = W.exec(query);
    W.commit();

    boost::json::object response_json;
    response_json["status"] = "success";
    response_json["message"] = "User created";
    response_json["username"] = R[0]["username"].as<std::string>();
    response_json["total_xp"] = R[0]["total_xp"].as<int>();
    response_json["daily_streak"] = R[0]["daily_streak"].as<int>();

    res.result(http::status::created);
    res.body() = boost::json::serialize(response_json);
}

void handle_leaderboard(const http::request<http::string_body> &req, http::response<http::string_body> &res, const char *db_url)
{
    pqxx::connection C(db_url);
    pqxx::nontransaction N(C);

    std::string query =
        "SELECT username, total_xp, daily_streak FROM users "
        "ORDER BY total_xp DESC, username  ASC "
        "LIMIT 10;";

    pqxx::result R = N.exec(query);

    boost::json::array users_array;
    for (auto const &row : R)
    {
        boost::json::object user_obj;
        user_obj["username"] = row["username"].as<std::string>();
        user_obj["total_xp"] = row["total_xp"].as<int>();
        user_obj["daily_streak"] = row["daily_streak"].as<int>();
        users_array.push_back(user_obj);
    }

    boost::json::object response_json;
    response_json["status"] = "success";
    response_json["leaderboard"] = users_array;

    res.result(http::status::ok);
    res.body() = boost::json::serialize(response_json);
}

void handle_submit_code(const http::request<http::string_body> &req, http::response<http::string_body> &res, const char *db_url)
{
    boost::json::value parsed_body = boost::json::parse(req.body());
    std::string language = parsed_body.at("language").as_string().c_str();

    // since google test only works for c++ im just gonna send an error message for now if its another language
    if (language != "cpp")
    {
        res.result(http::status::bad_request);
        res.body() = R"({"status": "error", "message": "Unsupported language. Currently, only C++ is supported."})";
        return;
    }

    std::string user_code = parsed_body.at("code").as_string().c_str();
    std::string problem_id = parsed_body.at("problem_id").as_string().c_str();

    // query database for the problems tests
    std::string test_code;
    {
        pqxx::connection C(db_url);
        pqxx::nontransaction N(C);

        std::string query = "SELECT test_code FROM problems WHERE id = " + N.quote(problem_id) + ";";
        pqxx::result R = N.exec(query);

        if (R.empty() || R[0]["test_code"].is_null())
        {
            res.result(http::status::not_found);
            res.body() = R"({"status": "error", "message": "Test code not found"})";
            return;
        }

        test_code = R[0]["test_code"].as<std::string>();
    }

    // we make temporary directory for user code and the tests
    auto uuid = boost::uuids::random_generator()();
    std::string session_id = boost::uuids::to_string(uuid);
    std::filesystem::path work_dir = std::filesystem::temp_directory_path() / "apollo_rce" / session_id;
    std::filesystem::create_directories(work_dir);

    std::ofstream(work_dir / "user_code.cpp") << user_code;
    std::ofstream(work_dir / "unit_tests.cpp") << test_code;

    // this is a script to run and test the code then save the output in a log file
    std::string script =
        "g++ -std=c++17 user_code.cpp unit_tests.cpp -lgtest -lgtest_main -pthread -o test_runner 2> compile_err.log\n"
        "if [ $? -ne 0 ]; then exit 42; fi\n" // Exit 42 means compilation failed
        "timeout 5 ./test_runner --gtest_output=json:result.json > run_out.log 2>&1\n"
        "EXIT_CODE=$?\n"
        "if [ $EXIT_CODE -eq 124 ]; then exit 124; fi\n" // Exit 124 means timeout
        "exit $EXIT_CODE\n";
    std::ofstream(work_dir / "run.sh") << script;

    // we run through docker so user code doesn't interfere with the server and let them run malware
    std::string docker_cmd = "docker run --rm --network none --memory 256m --cpus 1.0 --read-only --pids-limit 64 "
                             "-v " +
                             work_dir.string() + ":/workspace:rw -w /workspace gtest-env bash run.sh";

    int exit_code = std::system(docker_cmd.c_str());

    boost::json::object response_json;

    if (exit_code == 42) // 42 means it didnt complie
    {
        std::ifstream err_file(work_dir / "compile_err.log");
        std::string err_str((std::istreambuf_iterator<char>(err_file)), std::istreambuf_iterator<char>());

        response_json["status"] = "error";
        response_json["type"] = "compilation_error";
        response_json["message"] = err_str;
    }
    else if (exit_code == 124) // 124 means it took longer than 5 seconds to run
    {
        response_json["status"] = "error";
        response_json["type"] = "timeout";
        response_json["message"] = "Execution exceeded the 5-second time limit.";
    }
    else
    {
        // if it wrote tests ran then we check tests otherwise it failed but at runtime
        if (std::filesystem::exists(work_dir / "result.json"))
        {
            std::ifstream res_file(work_dir / "result.json");
            std::string res_str((std::istreambuf_iterator<char>(res_file)), std::istreambuf_iterator<char>());
            boost::json::value gtest_data = boost::json::parse(res_str);

            response_json["status"] = (exit_code == 0) ? "success" : "error";
            response_json["type"] = (exit_code == 0) ? "all_passed" : "test_failure";
            response_json["test_results"] = gtest_data;
        }
        else
        {
            // it actually turned out we didnt need to measure execution time because google test already does it
            std::ifstream out_file(work_dir / "run_out.log");
            std::string out_str((std::istreambuf_iterator<char>(out_file)), std::istreambuf_iterator<char>());

            response_json["status"] = "error";
            response_json["type"] = "runtime_error";
            response_json["message"] = "Program crashed during execution. Output: " + out_str;
        }
    }

    std::filesystem::remove_all(work_dir);
    res.result(http::status::ok);
    res.body() = boost::json::serialize(response_json);
}

// chooses the right endpoint for the request
void handle_request(const http::request<http::string_body> &req, http::response<http::string_body> &res)
{
    res.version(req.version());
    res.set(http::field::server, "Boost.Beast Backend");
    res.set(http::field::content_type, "application/json");
    res.keep_alive(req.keep_alive()); // so it doesn't have to restart connection after every request

    const char *db_url = std::getenv("DATABASE_URL");
    if (!db_url)
    {
        res.result(http::status::internal_server_error);
        res.body() = R"({"status": "error", "message": "Database configuration missing"})";
        res.prepare_payload();
        return;
    }

    try
    {
        if (req.method() == http::verb::post && req.target() == "/api/login")
        {
            handle_login(req, res, db_url);
        }
        else if (req.method() == http::verb::post && req.target() == "/api/signup")
        {
            handle_signup(req, res, db_url);
        }
        else if (req.method() == http::verb::get && req.target() == "/api/leaderboard")
        {
            handle_leaderboard(req, res, db_url);
        }
        else if (req.method() == http::verb::post && req.target() == "/api/submit_code")
        {
            handle_submit_code(req, res, db_url);
        }
        else if (req.method() == http::verb::post && req.target() == "/api/ask_ai")
        {
            handle_ask_ai(req, res);
        }
        else if (req.method() == http::verb::get && req.target().starts_with("/api/problems")){
            std::string target = std::string(req.target());
            std::string language = target.substr(target.find("=") + 1);

            pqxx::connection C(db_url);
            pqxx::nontransaction N(C);

            std::string query =
                "SELECT id, name, topic, difficulty FROM problems WHERE language =" + N.quote(language);

            pqxx::result R = N.exec(query);


            boost::json::array results;
            for (auto row : R) {
                boost::json::object item;
                item["id"] = row["id"].as<int>();
                item["name"] = row["name"].as<std::string>();
                item["topic"] = row["topic"].as<std::string>();
                item["difficulty"] = row["difficulty"].as<std::string>();
                results.push_back(item);
            }
            res.result(http::status::ok);
            res.body() = boost::json::serialize(results);

        }

        else if (req.method() == http::verb::get && req.target().starts_with("/api/problem?"))
        {
            std::string target = std::string(req.target());
            int problem_id = std::stoi(target.substr(target.find("=") + 1));

            pqxx::connection C(db_url);
            pqxx::nontransaction N(C);

            // Get problem details
            std::string problem_query =
                "SELECT name, description, initial_code FROM problems WHERE id = " + std::to_string(problem_id);
            pqxx::result problem_result = N.exec(problem_query);

            if (problem_result.empty())
            {
                res.result(http::status::not_found);
                res.body() = R"({"status": "error", "message": "Problem not found"})";
                res.prepare_payload();
                return;
            }

            // Get lessons for this problem
            std::string lessons_query =
                "SELECT title, content, slide_order FROM lessons WHERE problem_id = " + std::to_string(problem_id) +
                " ORDER BY slide_order ASC";
            pqxx::result lessons_result = N.exec(lessons_query);

            // Build response
            boost::json::object response_json;
            response_json["name"] = problem_result[0]["name"].as<std::string>();
            response_json["description"] = problem_result[0]["description"].as<std::string>();
            response_json["initial_code"] = problem_result[0]["initial_code"].as<std::string>();

            boost::json::array lessons_array;
            for (auto row : lessons_result)
            {
                boost::json::object lesson;
                lesson["title"] = row["title"].as<std::string>();
                lesson["content"] = row["content"].as<std::string>();
                lesson["slide_order"] = row["slide_order"].as<int>();
                lessons_array.push_back(lesson);
            }

            response_json["lessons"] = lessons_array; // Puts lessons_array in the reponse json

            res.result(http::status::ok);
            res.body() = boost::json::serialize(response_json);
        }

        else
        {
            res.result(http::status::not_found);
            res.body() = R"({"status": "error", "message": "Endpoint not found"})";
        }
    }
    catch (const pqxx::integrity_constraint_violation &e)
    {
        res.result(http::status::conflict);
        res.body() = R"({"status": "error", "message": "Username or Email already exists"})";
    }
    catch (const std::exception &e)
    {
        res.result(http::status::internal_server_error);
        res.body() = R"({"status": "error", "message": "An internal error occurred"})";
        std::cerr << "Server Error: " << e.what() << "\n";
    }

    res.prepare_payload();
}

// i switched it to be async so each thread handles a user connection
// which is an object of this type
class session : public std::enable_shared_from_this<session> // apparently this keeps the object from being deleted
{
    beast::tcp_stream stream_;
    beast::flat_buffer buffer_;
    http::request<http::string_body> req_;
    http::response<http::string_body> res_;

public:
    // now the class deals with this connection not listener
    explicit session(tcp::socket &&socket) : stream_(std::move(socket)) {}

    void run()
    {
        net::dispatch(stream_.get_executor(),
                      beast::bind_front_handler(&session::do_read, shared_from_this())); // the handler makes sure on_xxx is called after it finishes
    }

private:
    void do_read()
    {
        req_ = {};
        stream_.expires_after(std::chrono::seconds(30)); // if it takes too long we just timeout

        http::async_read(stream_, buffer_, req_,
                         beast::bind_front_handler(&session::on_read, shared_from_this()));
    }

    void on_read(beast::error_code ec, std::size_t bytes_transferred)
    {
        boost::ignore_unused(bytes_transferred);

        if (ec == http::error::end_of_stream)
            return do_close();

        if (ec)
        {
            std::cerr << "Read error: " << ec.message() << "\n";
            return;
        }

        handle_request(req_, res_);

        stream_.expires_after(std::chrono::seconds(30));
        http::async_write(stream_, res_,
                          beast::bind_front_handler(&session::on_write, shared_from_this()));
    }

    void on_write(beast::error_code ec, std::size_t bytes_transferred)
    {
        boost::ignore_unused(bytes_transferred);

        if (ec)
        {
            std::cerr << "Write error: " << ec.message() << "\n";
            return;
        }

        // close or continue handling requests depending on user
        if (!req_.keep_alive())
        {
            return do_close();
        }

        do_read();
    }

    void do_close()
    {
        beast::error_code ec;
        stream_.socket().shutdown(tcp::socket::shutdown_send, ec);
    }
};

// takes each user connection and gives it a thread to handle it
class listener : public std::enable_shared_from_this<listener>
{
    net::io_context &ioc_;
    tcp::acceptor acceptor_;

public:
    listener(net::io_context &ioc, tcp::endpoint endpoint)
        : ioc_(ioc), acceptor_(net::make_strand(ioc))
    {
        beast::error_code ec;
        acceptor_.open(endpoint.protocol(), ec);
        acceptor_.set_option(net::socket_base::reuse_address(true), ec);
        acceptor_.bind(endpoint, ec);
        acceptor_.listen(net::socket_base::max_listen_connections, ec);
    }

    void run()
    {
        do_accept();
    }

private:
    void do_accept()
    {
        // a strand makes it so every thread is handled one by one so they dont conflict
        acceptor_.async_accept(
            net::make_strand(ioc_),
            beast::bind_front_handler(&listener::on_accept, shared_from_this()));
    }

    void on_accept(beast::error_code ec, tcp::socket socket)
    {
        if (ec)
        {
            std::cerr << "Couldn't accept user: " << ec.message() << "\n";
        }
        else
        {
            std::make_shared<session>(std::move(socket))->run();
        }

        do_accept();
    }
};

int main()
{
    try
    {
        load_env();

        // get the amount of cores in the machine to know how many threads to make
        auto const threads = std::max<unsigned>(1, std::thread::hardware_concurrency());

        net::io_context ioc{static_cast<int>(threads)};
        tcp::endpoint endpoint{net::ip::make_address("0.0.0.0"), 8080};

        std::make_shared<listener>(ioc, endpoint)->run();

        std::cout << "Server running on port 8080..." << std::endl;

        // start up each thread
        std::vector<std::thread> v;
        v.reserve(threads - 1);
        for (auto i = threads - 1; i > 0; --i)
        {
            v.emplace_back([&ioc]
                           { ioc.run(); });
        }

        ioc.run();

        // since run() is blocking if we reach here the server is closing so we just close each thread
        for (auto &t : v)
            t.join();
    }
    catch (const std::exception &e)
    {
        std::cerr << "Fatal Error: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
