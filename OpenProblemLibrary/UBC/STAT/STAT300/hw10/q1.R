xS <- rmultinom(1, size=206, prob=c(0.41, 0.59))
xNS <- rmultinom(1, size=645, prob=c(0.24, 0.76))
table <- as.table(rbind(t(xS), t(xNS)))
dimnames(table) <- list(Smoke=c("Yes" ," No" ), Acne=c(" Present" ,"Absent" ))
beta0 <- round(runif(1, -4.5, -3.5),2)
beta1 <- round(runif(1, 0.6, 1.1),2)
beta2 <- round(runif(1, 0.1, 0.7),2)
beta3 <- round(runif(1, -0.6, -0.15),2)

as.vector(table)[c(1,3,2,4)]