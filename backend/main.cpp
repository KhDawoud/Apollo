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

    if (req.method() == http::verb::post && req.target() == "/api/login")
    {
        try
        {
            const char *db_url = std::getenv("DATABASE_URL");
            if (!db_url)
                throw std::runtime_error("DATABASE_URL missing.");

            boost::json::value parsed_body = boost::json::parse(req.body());
            std::string username = parsed_body.at("username").as_string().c_str();
            std::string raw_password = parsed_body.at("password").as_string().c_str();

            pqxx::connection C(db_url);
            pqxx::nontransaction N(C);

            std::string query =
                "SELECT total_xp FROM users WHERE email = " + N.quote(username) +
                " AND password_hash = crypt(" + N.quote(raw_password) + ", password_hash);";

            pqxx::result R = N.exec(query);

            if (!R.empty())
            {
                //account exists
                boost::json::object response_json;
                response_json["status"] = "success";
                response_json["total_xp"] = R[0]["total_xp"].as<int>();

                res.result(http::status::ok);
                res.body() = boost::json::serialize(response_json);
            }
            else
            {
                // no account
                boost::json::object response_json;
                response_json["status"] = "error";
                response_json["message"] = "Invalid username or password.";

                res.result(http::status::unauthorized);
                res.body() = boost::json::serialize(response_json);
            }
        }
        catch (const std::exception &e)
        {
            boost::json::object response_json;
            response_json["status"] = "error";
            response_json["message"] = "Server error occurred.";

            res.result(http::status::internal_server_error);
            res.body() = boost::json::serialize(response_json);
        }
    }
    else
    {
        res.result(http::status::not_found);
        res.body() = R"({"status": "error", "message": "Endpoint not found"})";
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
        return 1;
    }
    return 0;
}