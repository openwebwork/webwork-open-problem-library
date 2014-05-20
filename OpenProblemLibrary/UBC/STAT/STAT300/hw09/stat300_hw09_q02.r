set.seed(1)

xm <- round(rnorm(12, mean=0.96, sd=0.03),2)
err <- round(rnorm(length(xm), 0, 0.4),2)
ym <- abs(5.8 - 3*xm + err)
xf <- round(rnorm(10, mean=0.98, sd=0.03),2)
err <- round(rnorm(length(xf), 0, 0.4),2)
yf <- abs(5.8 - 3*xf + err)

# Data points can be extracted via, e.g.,
xm[1]

# The linear models and summary statistics can be created via
regr1 <- lm(ym ~xm)
summary1 <- summary(regr1)
sex <- as.factor(rep(c("Male","Female"),c(12,10)))
y <- c(ym,yf)
x <- c(xm,xf)
regr2 <- lm(y ~x*sex)
summary2 <- summary(regr2)

as.numeric(pf(c(summary2$fstat[1]), df1=3, df2=18, lower.tail=FALSE))


# a
as.numeric(summary1$coefficients[2])

# b
as.numeric(summary1$coefficients[8])

# c
as.numeric(summary2$r.sq)

# d
as.numeric(pf(c(summary2$fstat[1]), df1=3, df2=18, lower.tail=FALSE))

# e
