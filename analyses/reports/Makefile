# variable
COMMON_DEPS= posterior-check.Rmd\
	../stats/reaction-time_model.stan\
	../wrangling/analysis-data_prepare.R\
	../wrangling/psycholing-data_prepare.R

# recipes
.PHONY:\
	reports

reports:\
	posterior-check_median.html

# >>>>> concrete

posterior-check_median.html:\
	$(COMMON_DEPS)\
	../stats/reaction-time_analysis_median_summary.csv\
	../stats/reaction-time_analysis_median_draws.csv
	Rscript -e 'renv::activate(".."); rmarkdown::render("$<", params = list(measure = "median"))'

posterior-check_mean.html:\
	$(COMMON_DEPS)\
	reaction-time_analysis_mean_summary.csv\
	reaction-time_analysis_mean_draws.csv
	Rscript -e 'rmarkdown::render("$<", params = list(measure = "mean"))'

posterior-check_latent-mean.html:\
	$(COMMON_DEPS)\
	reaction-time_analysis_latent-mean_summary.csv\
	reaction-time_analysis_latent-mean_draws.csv
	Rscript -e 'rmarkdown::render("$<", params = list(measure = "latent-mean"))'
