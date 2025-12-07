"""visualize an epw file"""
from ladybug.epw import EPW
import matplotlib.pyplot as plt

epw_path = 'FRA_AR_Clermont-Ferrand.Auvergne.AP.074600_TMYx.2009-2023.epw'
with open(epw_path, 'r') as f:
    epw = EPW.from_file_string(f.read())

# Température extérieure
print(epw.dry_bulb_temperature)

plt.plot(epw.dry_bulb_temperature)
plt.xlabel("Heure")
plt.ylabel("Température (°C)")
plt.title("Température extérieure - Clermont-Ferrand")
plt.show()
