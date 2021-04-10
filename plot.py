import matplotlib.pyplot as plt

time = [600, 800, 1000, 1200, 1400, 1600, 1800, 2000, 2200, 2400]

newreno = [0.077068, 0.021771, 0.046267, 0.043259, 0.024609, 0.021640, 0.020837, 0.018810, 0.015794, 0.018096]
vegas = [0.305460, 0.183872, 0.162933, 0.135204, 0.103017, 0.126727, 0.089226, 0.087788, 0.079121, 0.079745]

newrenoObO = [0.095395, 0.057802, 0.053649, 0.038289, 0.033037, 0.038582, 0.032855, 0.028214, 0.024470, 0.020238]
vegasObO = [0.016378, 0.006232, 0.009765, 0.004145, 0.003522, 0.007682, 0.005428, 0.003665, 0.004471, 0.002048]

plt.plot(time, newreno, 'bo-', label="NewReno S1")
plt.plot(time, newrenoObO, 'bo:', label="NewReno S2")
plt.plot(time, vegas, 'ro-', label="Vegas S1")
plt.plot(time, vegasObO, 'ro:', label="Vegas S2")

plt.title("Loss rates of TCP agents Newreno and Vegas in two settings \n over different periods")

plt.xlabel("duration")
plt.ylabel("loss rate")

plt.text(1700, 0.2, "S1: SameTime \nS2: OneByOne")

plt.legend()
plt.show()

