#include <boost/filesystem.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/foreach.hpp>

#include <stdlib.h>
#include <iostream>
#include <sstream>

namespace fs = boost::filesystem;

void append_env(std::string const& var, std::string value)
{
  char* cOldValue = getenv(var.c_str());
  std::string oldValue ( (cOldValue? cOldValue : "") );

  if (!oldValue.empty() ) {
    value += ":" + oldValue;
  }

  setenv(var.c_str(), value.c_str(), /*overwrite*/ 1);
}


void append_env_from_file(fs::path const& envFile)
{
  fs::ifstream input(envFile);

  std::string var;
  std::string value;

  while( input >> var >> value ) {
    append_env(var, value);
  }

}

int main(int argc, char** argv)
{
  fs::path wrapper_dir( WRAPPER_DIR  );

  fs::directory_iterator it(wrapper_dir), eod;

  BOOST_FOREACH(fs::path const &p, std::make_pair(it, eod)) {
    if(is_regular_file(p) && p.extension() == ".wrp" ) {
      append_env_from_file(p);
    }
  }

  std::ostringstream buf;

  for (int i = 1; i < argc; ++i) {
    buf << argv[i] << ' ';
  }

  if ( system( buf.str().c_str() ) == 0 ) {
    return 0;
  }  else {
    perror(NULL);
    return 1;
  }
}
