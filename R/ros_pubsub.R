real_time <- c(4647.609275461621, 4914.350042001504, 10817.46587170375, 32410.539184549638, 83764.88011132626, 1044106.2189312959, 3573191.76375081, 20928469.642888427, 84531585.93753187)
cpu_time <- c(3996.525072522072, 4390.631452501739, 10111.225631437, 30571.879910891334, 80272.52386504423, 996014.952023052, 3540859.590603914, 20107569.845712792, 83198716.40000471)
bytes_per_second <- c(220334104.45400634, 833495450.3921818, 1552375281.0753336, 2039646241.2514234, 3139900191.558425, 1004412110.5288732, 1226689567.3281274, 802032047.0617198, 794131967.7890902)
manual_bandwidth <- c(233548707.55889267, 517619176.04281694, 3521025198.331669, 1267576171.691979, 692023701.5569701, 175012270.98146084, 28570435.29598547, 19075255.851903733, 17661296.76422714)
manual_latency <- c(98645086.48662971, 79166648.66358423, 12683969.933360163, 45286113.04486585, 78444876.04642949, 101784359.23296383, 376512161.325, 1282624062.85, 3802408177.5)

#ros_pubsub_l
df <- data.frame("factor"=size, "Время отправки (нс)"=real_time, "Время отправки CPU (нс)"=cpu_time, "Широта пропускания публикующего (б/с)"=bytes_per_second, "Широта пропускания принимающего (б/с)"=manual_bandwidth, "Задержка передачи (нс)"=manual_latency)
plot(factor(size, levels=size), real_time / 1000000000, type="o", col="black", lty=0, ylim=c(-4, 4), xlab="", ylab="")
points(factor(size, levels=size), real_time / 1000000000, col="black", pch="o")
lines(factor(size, levels=size), real_time / 1000000000, col="black", lty=1, lwd=2)
points(factor(size, levels=size), cpu_time / 1000000000, col="red", pch="X")
lines(factor(size, levels=size), cpu_time / 1000000000, col="red", lty=2, lwd=2)
points(factor(size, levels=size), manual_latency / 1000000000, col="blue", pch="V")
lines(factor(size, levels=size), manual_latency / 1000000000, col="blue", lty=3, lwd=2)
title(xlab="Размер сообщения", ylab="Задержка (с)")
legend("bottomright", legend=c("Время отправки", "Время отправки CPU", "Задержка передачи"), col=c("black", "red", "blue"), lty=c(1, 2, 3), pch=c("o", "X"), ncol=1)

mbps = manual_bandwidth / (1024*1024)
# ros_pubsub_bw
m <- rbind(manual_bandwidth  / (1024*1024), bytes_per_second  / (1024*1024))
barplot(m, names.arg = factor(size, levels = size), beside = TRUE, col = c("blue", "red"), xlab = "Размер сообщения", ylab = "Пропускная способность (Мб/с)", ylim = c(0, 4000))
legend("topright", c("Для подписчика", "Для издателя"), fill = c("blue", "red"))
