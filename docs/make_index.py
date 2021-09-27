import os

root = '/var/www/'
with open(os.path.join(root, 'index.html'), 'w') as ofp:
    ofp.write("""<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>Pendulum Software Documentation</title>
  <meta name="description" content="sorfware and workflow documentation">
  <meta name="author" content="Pendulum Therapeutics">

  <link rel="stylesheet" href="style.css">

</head>

<body>
<h1>Pendulum Software Documentation</h1>
<ul>
""")

    for f in sorted(os.listdir(root)):
        if os.path.isdir(os.path.join(root,f)):
            if 'workflows' in f:
                ofp.write('<li>Workflows<ul>')
                for w in sorted(os.listdir(os.path.join(root, f))):
                    if os.path.isdir(os.path.join(root, f, w)):
                        ofp.write(f'<li><a href="{f}/{w}">{w}</a></li>')
                ofp.write('</ul></li>')
            elif 'operators' in f:
                ofp.write('<li>Operators<ul>')
                for w in sorted(os.listdir(os.path.join(root, f))):
                    if os.path.isdir(os.path.join(root, f, w)):
                        ofp.write(f'<li><a href="{f}/{w}">{w}</a></li>')
                ofp.write('</ul></li>')
            else:
                ofp.write(f'<li><a href="{f}">{f}</a></li>')


    ofp.write("""</ul>
    </body>
    <footer>
    <a href="about.html">About</a>
    </footer>
</html>""")
