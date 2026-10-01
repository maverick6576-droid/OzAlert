import codecs
import re

with codecs.open('lib/presentation/providers/paywall_provider.dart', 'r', 'utf-8') as f:
    text = f.read()

old_line = "if (user != null && user.email == 'maverick6576+Ozspain@gmail.com') {"
new_line = "final vipEmails = ['maverick6576@gmail.com', 'juditmaynou2000@gmail.com'];\n    if (user != null && user.email != null && vipEmails.contains(user.email)) {"

text = text.replace(old_line, new_line)

with codecs.open('lib/presentation/providers/paywall_provider.dart', 'w', 'utf-8') as f:
    f.write(text)
print("Correos VIP actualizados")
