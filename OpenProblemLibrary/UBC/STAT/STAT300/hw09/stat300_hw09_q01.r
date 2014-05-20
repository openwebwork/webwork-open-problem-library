set.seed(1)
x <- round(runif(99, min=2.3, max=5),2)
err <- round(rnorm(length(x), 0, 18),2)
y <- abs(83 - 15*x + err)

# Scatterplot
plot(x,y,xlab='Friend-reported agreeableness',ylab='Daily no. of words on FaceBook entries',main='FaceBook Activity against Friend-reported Agreeableness Rating')

# There are several ways to …t the linear model and produce summary
# statistics, such as
regr1 <- lm(y ~x)
summary1 <- summary(regr1)

# From the above object the relevant statistics can be extracted as follows:
summary1$coefficients[1]
summary1$coefficients[2]
summary1$coefficients[4]

# The above give the intercept, slope, and the estimated standard deviation of the slope estimate respectively. All of these can be rounded using, for instance
round(summary1$coefficients[4],3)

# Stuff for question
slope <- round(summary1$coeff[2],3)
intercept <- round(summary1$coeff[1],3)
se_slope <- round(summary1$coefficients[4],3)


# Answer to b
se_b1_hat <- round(summary1$coefficients[4],3)
q_b1_hat <- qt(c(0.975), df=97, lower.tail=TRUE)
b1_hat <- summary1$coefficients[2]
# Lower and upper
c(b1_hat-se_b1_hat*q_b1_hat, b1_hat+se_b1_hat*q_b1_hat)

# Answer to c
summary1$coeff[6]

summary1$coeff[2]/summary1$coeff[4]

# P value
summary1$coefficients[8]