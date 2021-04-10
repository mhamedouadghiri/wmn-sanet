BEGIN {
  rcv_16_reno = 0
  sent_16_reno = 0
  rcv_05_vegas = 0
  sent_05_vegas = 0
}
{
  if ($7 == "tcp" && $4 == "AGT") {
    if ($3 == "_0_" && $1 == "s") sent_05_vegas++
    if ($3 == "_1_" && $1 == "s") sent_16_reno++
    if ($3 == "_5_" && $1 == "r") rcv_05_vegas++
    if ($3 == "_6_" && $1 == "r") rcv_16_reno++
  } 
}
END {
  loss_rate_reno = 100 * (1 - rcv_16_reno / sent_16_reno)
  loss_rate_vegas = 100 * (1 - rcv_05_vegas / sent_05_vegas)

  printf("NewReno sent = %d, rcv  = %d, loss rate = %f\n",
	 sent_16_reno, rcv_16_reno, loss_rate_reno)
  printf("Vegas sent = %d, rcv = %d, loss rate = %f\n",
	 sent_05_vegas, rcv_05_vegas, loss_rate_vegas)
}
