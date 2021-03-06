require(ggplot2)

f <- commandArgs(TRUE)[1]

d <- read.table(f, sep=' ', header=T)

d$gb_per_s <- d$mb_per_s / 1000
d$gb_per_s_dev <- d$ns_dev / d$ns * d$gb_per_s

do_plot <- function(data, facets) {
  ggplot(data, aes(reader, gb_per_s, fill=reader)) +
    geom_bar(stat='identity', position='dodge', width=0.7, colour='black', size=0.2) +
    geom_errorbar(aes(ymin=gb_per_s - gb_per_s_dev, ymax=gb_per_s + gb_per_s_dev), width=0.2, alpha=0.5) +
    facet_grid(paste(paste(facets, collapse= "+"), " ~ ."), space='free_y', scale='free_y') +
    scale_x_discrete(expand=c(.1, .1)) +
    coord_cartesian(ylim=c(.3, 1)) + 
    expand_limits(y=0, x=0) +
    scale_fill_grey(start=0, end=1) +
    labs(x='reader', y='GB/s') +
    theme_bw() + theme(
      strip.text.y = element_text(angle=0),
      strip.background = element_rect(fill = "white", colour = "gray50"),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank()
    ) +
    coord_flip()
}

for (m in unique(d$format)) {
    sub <- subset(d, format==m)
    png(file.path(dirname(f), sprintf('bench_%s.png', m)), width=1400, height=45*nrow(sub)+150, res=200)
    print(do_plot(sub, c('seqlen', 'method', 'other', 'parallel', 'owned')))
    dev.off()
    
    sub <- subset(sub, method == 'iter' & seqlen == 500 & other != 'records')
    png(file.path(dirname(f), sprintf('bench_%s_simple.png', m)), width=1400, height=45*nrow(sub)+150, res=200)
    print(do_plot(sub, c('seqlen', 'other', 'parallel', 'owned')))
    dev.off()
}
