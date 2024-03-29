/*
 This is a small noop file so bundlex has something to compile on non-linux machines.
 The code below is the smallest nif loading code (from the erlang docs) since typically
 unifex will add it, however, we don't want to include unifex here.
 */
#include <erl_nif.h>

static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
}

static ErlNifFunc nif_funcs[] =
{
    {"hello", 0, hello}
};

ERL_NIF_INIT(niftest,nif_funcs,NULL,NULL,NULL,NULL)
