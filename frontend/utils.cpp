#include "utils.hpp"
void checkemail(std::string email){
    std::regex pattern(R"(.+@.+\.com)");
    if(!std::regex_match(email,pattern)){
        throw std::invalid_argument("no match");
    }
}