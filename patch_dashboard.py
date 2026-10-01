# -*- coding: utf-8 -*-
import codecs

with codecs.open('lib/presentation/screens/dashboard/dashboard_screen.dart', 'r', 'utf-8') as f:
    text = f.read()

old_block = "const SizedBox(height: 10),"
new_block = '''const SizedBox(height: 10),
                const StatisticsCard(),
                const SizedBox(height: 32),'''

if old_block in text:
    text = text.replace(old_block, new_block)
    print("Dashboard parcheado correctamente")
else:
    print("No se encontro old_block de nuevo")

with codecs.open('lib/presentation/screens/dashboard/dashboard_screen.dart', 'w', 'utf-8') as f:
    f.write(text)
