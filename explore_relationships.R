# Plot relationships ------------------------------------------------------

ggplot(st, aes(x = log10(h_index), y = Total, col = region)) + geom_point() +
  geom_smooth() + ylab("TOP factor") + xlab("log10(H-Index)") + theme_bw() +
  ggtitle(paste("r = ", round(cor(log10(st$h_index), st$Total, method = "pearson", use = "complete.obs"), digits = 3), sep = ""))

ggplot(st, aes(x = log10(sjr), y = Total, col = region)) + geom_point() +
  geom_smooth() + ylab("TOP factor") + xlab("log10(Scimago Journal Rank)") + theme_bw() +
  ggtitle(paste("r = ", round(cor(log10(st$sjr), st$Total, method = "pearson", use = "complete.obs"), digits = 3), sep = ""))


ggplot(st, aes(x = Publisher, y = Replication.score)) + geom_violin() + coord_flip()
