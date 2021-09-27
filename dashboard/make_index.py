import os

root = '/var/www/'
with open(os.path.join(root, 'index.html'), 'w') as ofp:
    ofp.write("""<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>Pendulum Dashboards</title>
  <meta name="description" content="Analysis and workflow dashboards for tracking experiments">
  <meta name="author" content="Pendulum Therapeutics">

  <link rel="stylesheet" href="style.css">

</head>

<body>
<h1>Pendulum analysis dashboards</h1>
<ul>
""")

    for f in os.listdir(root):
        if os.path.isdir(os.path.join(root,f)):
            ofp.write(f'<li><a href="{f}">{f}</a></li>')


    ofp.write("""</ul>
    </body>
</html>""")
