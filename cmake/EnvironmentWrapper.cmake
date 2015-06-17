include( CMakeParseArguments )

set( WRAPPER_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/wrapper CACHE INTERNAL "" )

# ensure no old wrapper files stay around
file( REMOVE_RECURSE ${WRAPPER_DIR} )
file( MAKE_DIRECTORY ${WRAPPER_DIR} )

add_executable( env_wrapper ${CMAKE_SOURCE_DIR}/cmake/EnvironmentWrapper.cpp )
target_compile_definitions( env_wrapper PRIVATE "-DWRAPPER_DIR=\"${WRAPPER_DIR}\"" )
target_include_directories( env_wrapper PRIVATE ${Boost_INCLUDE_DIRS} )
target_link_libraries( env_wrapper PRIVATE ${Boost_FILESYSTEM_LIBRARY} ${Boost_SYSTEM_LIBRARY} )

function( add_wrapper name )

  set( flags )
  set( single )
  set( multi PATH LIB )
  cmake_parse_arguments( arg "${flags}" "${single}" "${multi}" ${ARGN} )

  set( theFilePath "${WRAPPER_DIR}/${name}.wrp" )

  set( content "" )

  foreach( path ${arg_PATH} )
    if( TARGET "${path}" )
      set( content "${content}\nPATH $<TARGET_FILE_DIR:${path}>" )
    elseif( IS_DIRECTORY "${path}" )
      set( content "${content}\nPATH ${path}" )
    elseif( EXISTS "${path}" )
      get_filename_component( dir ${path} PATH )
      set( content "${content}\nPATH ${dir}" )
    else( )
      message( FATAL_ERROR "invalid specification add_wrapper( ${name} PATH ${path} )" )
    endif( )
  endforeach( )

  foreach( path ${arg_LIB} )
    if( TARGET "${path}" )
      set( content "${content}\nLD_LIBRARY_DIR $<TARGET_FILE_DIR:${path}>" )
    elseif( IS_DIRECTORY "${path}" )
      set( content "${content}\nLD_LIBRARY_DIR ${path}" )
    elseif( EXISTS "${path}" )
      get_filename_component( dir ${path} PATH )
      set( content "${content}\nLD_LIBRARY_DIR ${dir}" )
    else( )
      message( FATAL_ERROR "invalid specification add_wrapper( ${name} LIB ${path} )" )
    endif( )
  endforeach( )

  file( GENERATE OUTPUT ${theFilePath} CONTENT "${content}" )

endfunction( )
