//Backend
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <boost/config.hpp>
#include <boost/json/src.hpp>
#include <pqxx/pqxx>
#include <iostream>
#include <string>
#include <fstream>
#include <cstdlib>

namespace beast = boost::beast;
namespace http = beast::http;
namespace net = boost::asio;
using tcp = boost::asio::ip::tcp;

// so i dont push my api key to github
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

void handle_request(http::request<http::string_body> &req, http::response<http::string_body> &res)
{
    res.version(req.version());
    res.set(http::field::server, "Boost.Beast Backend");
    res.set(http::field::content_type, "application/json");

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
            boost::json::value parsed_body = boost::json::parse(req.body());
            std::string identifier = parsed_body.at("identifier").as_string().c_str();
            std::string raw_password = parsed_body.at("password").as_string().c_str();

            pqxx::connection C(db_url);
            pqxx::nontransaction N(C);

            std::string query =
                "SELECT username, total_xp FROM users WHERE (email = " + N.quote(identifier) +
                " OR username = " + N.quote(identifier) + ") " +
                "AND password_hash = crypt(" + N.quote(raw_password) + ", password_hash);";

            pqxx::result R = N.exec(query);

            if (!R.empty())
            {
                boost::json::object response_json;
                response_json["status"] = "success";
                response_json["username"] = R[0]["username"].as<std::string>();
                response_json["total_xp"] = R[0]["total_xp"].as<int>();

                res.result(http::status::ok);
                res.body() = boost::json::serialize(response_json);
            }
            else
            {
                res.result(http::status::unauthorized);
                res.body() = R"({"status": "error", "message": "Invalid credentials"})";
            }
        }
        else if (req.method() == http::verb::post && req.target() == "/api/signup")
        {
            boost::json::value parsed_body = boost::json::parse(req.body());
            std::string email = parsed_body.at("email").as_string().c_str();
            std::string username = parsed_body.at("username").as_string().c_str();
            std::string raw_password = parsed_body.at("password").as_string().c_str();

            pqxx::connection C(db_url);
            // this makes sure data isnt corrupted if something fails
            pqxx::work W(C);

            std::string query =
                "INSERT INTO users (email, username, password_hash) VALUES (" +
                W.quote(email) + ", " +
                W.quote(username) + ", " +
                "crypt(" + W.quote(raw_password) + ", gen_salt('bf'))) " +
                "RETURNING username, total_xp;";

            pqxx::result R = W.exec(query);
            W.commit();

            boost::json::object response_json;
            response_json["status"] = "success";
            response_json["message"] = "User created";
            response_json["username"] = R[0]["username"].as<std::string>();
            response_json["total_xp"] = R[0]["total_xp"].as<int>();

            res.result(http::status::created);
            res.body() = boost::json::serialize(response_json);
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
        // this is specifically when u try to login with same email or name as somemone else
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

int main()
{
    try
    {
        load_env();
        net::io_context ioc;
        tcp::acceptor acceptor(ioc, {net::ip::make_address("0.0.0.0"), 8080});

        std::cout << "Server running on port 8080..." << std::endl;

        while (true)
        {
            tcp::socket socket(ioc);
            acceptor.accept(socket);
            beast::flat_buffer buffer;
            http::request<http::string_body> req;
            http::response<http::string_body> res;

            http::read(socket, buffer, req);
            handle_request(req, res);
            http::write(socket, res);

            beast::error_code ec;
            socket.shutdown(tcp::socket::shutdown_send, ec);
        }
    }
    catch (const std::exception &e)
    {
        std::cerr << "Fatal Error: " << e.what() << std::endl;
        return 1;
    }
    return 0;
}
