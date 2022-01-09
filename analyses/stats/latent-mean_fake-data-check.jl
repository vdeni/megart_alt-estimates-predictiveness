using Pkg
Pkg.activate("..")

using DataFrames
using CmdStan

CmdStan.set_cmdstan_home!(homedir() * "/.cmdstanr/cmdstan-2.27.0")

# read stan model from external file
stan_script = read("latent-mean_model.stan",
                   String)

model = CmdStan.Stanmodel(CmdStan.Sample();
                          name = "latent-mean",
                          nchains = 6,
                          num_warmup = 2e3,
                          num_samples = 3e3,
                          model = stan_script,
                          tmpdir = pwd() * "/latent-mean_tmp",
                          output_format = :dataframes)

d = Dict("Y" => [1, 5, 4, 3, 3, 3, 5, 4, 4, 5, 2, 2, 5, 5, 3, 2, 5, 3, 2, 5, 5,
                 5, 5, 5, 5, 3, 2, 5, 4, 5],
         "K" => 5,
         "N" => 30,
         "c_1" => 1.5,
         "c_4" => 4.5)

rc, samples, varnames = CmdStan.stan(model,
                                     d;
                                     diagnostics = true) 
