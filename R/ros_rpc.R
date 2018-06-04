real_time <- c(953685.2691267472, 979528.1199712123, 1057962.4634684217, 1101019.5262034556, 16208963.116655976, 6030580.885001199, 14460727.4104222, 50117277.2285567, 276020631.85022414)
cpu_time <- c(322553.1072570725, 322758.7631504921, 326605.58646986476, 345976.2866855526, 446579.5666666593, 635461.9456249997, 2243157.250000002, 4666441.657142859, 57243083.19999993)
bytes_per_second <- c(2150095.0702272914, 8398018.33243535, 31059254.2002196, 119372696.41049369, 153667719.02438125, 379524282.90441144, 581071394.0045922, 669678524.6846191, 486639880.40417826)
req_t <- c(4133046.6, 4149062.7, 4217649.9, 4202854.5, 70529160.0, 16443369.8, 27409928.5, 43983998.4, 293352139.7)
resp_t <- c(62681.1, 74235.6, 82369.6, 631606.4, 595521.6, 10180450.4, 35101911.7, 170881060.4, 806409003.2)

# ros_rpc_l_k
m <- rbind((req_t  / (1000000))[1:4], (resp_t  / (1000000))[1:4])
barplot(m, names.arg = factor(size[1:4], levels = size[1:4]), col = c("blue", "red"), xlab = "Размер сообщения", ylab = "Задержка передачи (мс)", ylim = c(0, 8))
legend("topright", c("Запрос", "Ответ"), fill = c("blue", "red"))

# ros_rpc_l_m
m <- rbind((req_t  / (1000000))[5:10], (resp_t  / (1000000))[5:10])
barplot(m, names.arg = factor(size[5:10], levels = size[5:10]), col = c("blue", "red"), xlab = "Размер сообщения", ylab = "Задержка передачи (мс)", ylim = c(0, 1500))
legend("topright", c("Запрос", "Ответ"), fill = c("blue", "red"))

# ros_rpc_bps
plot(factor(size, levels=size), bytes_per_second / (1024*1024), type="o", col="black", lty=0, ylim=c(-10, 700), xlab="", ylab="")
points(factor(size, levels=size), bytes_per_second / (1024*1024), col="black", pch="o")
lines(factor(size, levels=size), bytes_per_second / (1024*1024), col="black", lty=1, lwd=2)
title(xlab="Размер сообщения", ylab="Пропускная способность (Мб/с)")

# ros_rpc_pubsub
rpc_t <- req_t + resp_t
ps_t <- c(98645086.48662971, 79166648.66358423, 12683969.933360163, 45286113.04486585, 78444876.04642949, 101784359.23296383, 376512161.325, 1282624062.85, 3802408177.5)
plot(factor(size, levels=size), rpc_t / (1000000000), type="o", col="black", lty=0, ylim=c(-3, 5), xlab="", ylab="")
points(factor(size, levels=size), rpc_t / (1000000000), col="black", pch="o")
lines(factor(size, levels=size), rpc_t / (1000000000), col="black", lty=1, lwd=2)
points(factor(size, levels=size), ps_t / (1000000000), col="red", pch="X")
lines(factor(size, levels=size), ps_t / (1000000000), col="red", lty=2, lwd=2)
title(xlab="Размер сообщения", ylab="Задержка (с)")
legend("bottomright", legend=c("Сервис-клиент", "Издатель-подписчик"), col=c("black", "red"), lty=c(1, 2), pch=c("o", "X"), ncol=1)
