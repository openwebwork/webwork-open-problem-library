runs.test2 <- function(x) { rtab <- table(x); nms <- names(rtab); rtab <- unname(rtab); n <- rtab[1]; m <- rtab[2]; N <- n + m; flips <- ifelse(x == nms[1], 0, 1); dflips <- c(1, abs(diff(flips))); R <- sum(dflips != 0); mu <- 2 * n * m/N + 1; vr <- (mu - 1) * (mu - 2)/(N - 1); sigma <- sqrt(vr); if (N > 50) { Z <- (R - mu)/sigma } else if ((R - mu) < 0) { Z = (R - mu + 0.5)/sigma } else { Z = (R - mu - 0.5)/sigma }; pval <- 2 * (1 - pnorm(abs(Z))); return(list(Z = Z, p.value = pval)); }

Cd <- arima.sim(list(ar=0.9), sd=0.01, n=30)
Cd <- round(Cd + 2.1, 3)
plot(Cd, main="Brazilian Real against Canadian dollar", ylab="BRL per C $")
runCd <- factor(sign(Cd - mean(Cd)))
runstestCd <- runs.test2(runCd)

plot(Cd[1:9], Cd[2:10], xlab="x(t)", ylab="x(t+1)")
plot(Cd[2:10], Cd[1:9], xlab="x(t)", ylab="x(t+1)")
plot(Cd[1:9], Cd[1:9], xlab="x(t)", ylab="x(t+1)")
plot(Cd[1:9], c(1:9), xlab="x(t)", ylab="x(t+1)")

signif(runstestCd$p.value, 3)

library(tseries)
runstestCd <- runs.test(runCd)
runstestCd2 <- runs.test2(runCd)


runs.test <- function(x, alternative = c("two.sided", "less", "greater")) { alternative <- match.arg(alternative); DNAME <- deparse(substitute(x)); n <- length(x); R <- 1 + sum(as.numeric(x[-1] != x[-n])); n1 <- sum(levels(x)[1] == x); n2 <- sum(levels(x)[2] == x); m <- 1 + 2 * n1 * n2/(n1 + n2); s <- sqrt(2 * n1 * n2 * (2 * n1 * n2 - n1 - n2)/((n1 + n2)^2 *(n1 + n2 - 1))); STATISTIC <- (R - m)/s; METHOD <- "Runs Test"; if (alternative == "two.sided") { PVAL <- 2 * pnorm(-abs(STATISTIC)) } else if (alternative == "less") {  PVAL <- pnorm(STATISTIC) } else if (alternative == "greater") { PVAL <- pnorm(STATISTIC, lower.tail = FALSE) } else { stop("irregular alternative") } ; names(STATISTIC) <- "Standard Normal"; structure(list(statistic = STATISTIC, alternative = alternative, p.value = PVAL, method = METHOD, data.name = DNAME), class = "htest") }