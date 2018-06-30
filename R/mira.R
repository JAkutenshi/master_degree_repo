size <- c("1K", "4K", "16K", "64K", "256K", "1M", "4M", "16M", "64M")

ps_real_time_i <- c(1794.7186319, 1656.0838081999998, 1657.7157215, 1630.5704070999998, 1616.5322531, 1503.7493749999999, 1543.3212322999998, 1571.2986896999998, 1589.9019902000002)
ps_cpu_time_i <- c(1795.864012, 1655.8415681, 1657.9540108, 1630.9049162000001, 1616.7235234999996, 1503.4641225, 1543.3403649, 1571.571565, 1590.60727)
ps_bytes_per_second_i <- c(4853778.761585699, 83407865.56992581, 827121360.8949069, 3867483129.867816, 16152920547.767572, 69569598974.06021, 273245737099.94342, 1073081021196.8617, 4239222165995.8594)
ps_manual_time_i <- c(3887.3, 4526.4, 3955.5, 3621.7, 5747.3, 3637.3, 3016.8, 3380.0, 4113.9)
ps_manual_bps_i <- c(27558159.649204694, 131191703.4346489, 425539842.24463284, 2045345401.1722145, 7049883608.697081, 30478477481.634228, 147734504859.9131, 514920585433.5671, 2164415352358.4302)

ps_real_time_o <- c(1122.6468948, 1109.8495050000001, 1091.7597360000002, 1185.7989599, 894.1334531, 960.8632263000002, 1067.0151218, 918.6111011, 890.4206820999998)
ps_cpu_time_o <- c(1119.9821877999998, 1106.9932056, 1088.6530892, 1183.3674303000003, 886.7807753999999, 952.0783027, 1058.0215409, 911.7032061999998, 883.5805469999999)
ps_bytes_per_second_o <- c(8113368.4283499, 131560437.0188622, 1295662393.2351851, 5635256834.389523, 29046179175.038452, 109050619333.65392, 397820664918.36224, 1831473562830.4902, 7542320470154.612)
ps_manual_time_o <- c(6118035.8, 14367990.7, 22488837.2, 9313783.0, 6840089.6, 8817207.8, 12587785.0, 28643665.2, 60538946.8)
ps_manual_bps_o <- c(30619.416385, 35082.9929197, 76106.4533962, 740431.6069606, 3901140.533323, 12095738.4135749, 33809618.682818905, 59159007.803795494, 17893148.120781202)

rpc_real_time <- c(228480.6996655, 239069.72307689994, 294043.2237461, 599405.5929765, 2757791.1197324, 12549108.428762604, 39024540.451505, 165139375.3227425, 919160538.9933112)
rpc_cpu_time <- c(228600.6841527, 239188.76460180004, 294157.8857295, 599542.3858202, 2757913.4674674, 12549268.2256256, 39024988.17490201, 165140909.2456502, 919168332.6944578)
rpc_bytes_per_second <- c(864406.1567993, 3397639.180548, 11157012.311954897, 21859116.7171818, 19169743.0961094, 16827996.9726744, 21515874.492444903, 20319110.0058807, 14618378.7690909)

ps_manual_gbps_i    <- ps_manual_bps_i / (1024*1024*1024)
ps_manual_gbps_o    <- ps_manual_bps_o / (1024*1024*1024)
rpc_mb_per_second <- rpc_bytes_per_second  / (1024*1024)

ps_manual_time_ms_o <- ps_manual_time_o / 1000000
rpc_real_time_ms    <- rpc_real_time    / 1000000
ps_manual_time_ms_i <- ps_manual_time_i / 1000000

#mira_res_rpc_bps
plot(factor(size, levels=size), rpc_mb_per_second, type="o", col="black", lty=0, ylim=c(0, 22), xlab="", ylab="")
points(factor(size, levels=size), rpc_mb_per_second, col="black", pch="o")
lines(factor(size, levels=size), rpc_mb_per_second, col="black", lty=1, lwd=2)
title(xlab="Размер сообщения", ylab="Пропускная способность (МБ/с)")

#mira_res_rpc_pubsub
plot(factor(size, levels=size), ps_manual_time_ms_o, type="o", col="black", lty=0, ylim=c(-300, 1000), xlab="", ylab="")
points(factor(size, levels=size), ps_manual_time_ms_o, col="black", pch="o")
lines(factor(size, levels=size), ps_manual_time_ms_o, col="black", lty=1, lwd=2)
points(factor(size, levels=size), rpc_real_time_ms, col="red", pch="X")
lines(factor(size, levels=size), rpc_real_time_ms , col="red", lty=2, lwd=2)
title(xlab="Размер сообщения", ylab="Задержка (мс)")
legend("bottomright", legend=c("Издатель-подписчик", "Сервис-клиент"), col=c("black", "red"), lty=c(1, 2), pch=c("o", "X"), ncol=1)

# mira_res_i_o_ml
plot(factor(size, levels=size), ps_manual_time_ms_o, type="o", col="black", lty=0, ylim=c(-20, 60), xlab="", ylab="")
points(factor(size, levels=size), ps_manual_time_ms_o, col="black", pch="o")
lines(factor(size, levels=size), ps_manual_time_ms_o, col="black", lty=1, lwd=2)
points(factor(size, levels=size), ps_manual_time_ms_i, col="red", pch="X")
lines(factor(size, levels=size), ps_manual_time_ms_i, col="red", lty=2, lwd=2)
title(xlab="Размер сообщения", ylab="Задержка (мс)")
legend("bottomright", legend=c("В различных процессах", "Внутри одного процесса"), col=c("black", "red"), lty=c(1, 2), pch=c("o", "X"), ncol=1)

# mira_res_i_o_sl
plot(factor(size, levels=size), ps_real_time_o, type="o", col="black", lty=0, ylim=c(0, 2000), xlab="", ylab="")
points(factor(size, levels=size), ps_real_time_o, col="black", pch="o")
lines(factor(size, levels=size), ps_real_time_o, col="black", lty=1, lwd=2)
points(factor(size, levels=size), ps_real_time_i, col="red", pch="X")
lines(factor(size, levels=size), ps_real_time_i, col="red", lty=2, lwd=2)
title(xlab="Размер сообщения", ylab="Задержка (нс)")
legend("bottomright", legend=c("В различных процессах", "Внутри одного процесса"), col=c("black", "red"), lty=c(1, 2), pch=c("o", "X"), ncol=1)

# mira_res_i_o_bps
plot(factor(size, levels=size), ps_manual_gbps_o, type="o", col="black", lty=0, ylim=c(-1000, 3000), xlab="", ylab="")
points(factor(size, levels=size), ps_manual_gbps_o, col="black", pch="o")
lines(factor(size, levels=size), ps_manual_gbps_o, col="black", lty=1, lwd=2)
points(factor(size, levels=size), ps_manual_gbps_i, col="red", pch="X")
lines(factor(size, levels=size), ps_manual_gbps_i, col="red", lty=2, lwd=2)
title(xlab="Размер сообщения", ylab="Пропускная способность (ГБ/с)")
legend("bottomright", legend=c("В различных процессах", "Внутри одного процесса"), col=c("black", "red"), lty=c(1, 2), pch=c("o", "X"), ncol=1)
