# fix HP Gen8 Microserver broken power mgt
kernel-modules:
  kmod.present:
    - persist: True
    - mods:
      - ipmi_si
      - acpi_ipmi
    - require: 
      - file: blacklist-acpi_power_meter

# prevent acpi_power_meter from being loaded
blacklist-acpi_power_meter:
  file.managed:
    - name: /etc/modprobe.d/blacklist_acpi_power_meter.conf
    - contents: blacklist acpi_power_meter
    - user: root
    - group: root
    - mode: 644

disk-scheduler-rules:
  file.managed:
    - name: /etc/udev/rules.d/00-ssd-scheduler.rules
    - source: salt://kernel/files/00-ssd-scheduler.rules

