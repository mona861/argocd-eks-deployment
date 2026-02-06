from flask import Flask, render_template_string

app = Flask(__name__)

# Easy configuration - change these values to customize your deployment
BACKGROUND_COLOR = "green"
DEPLOYMENT_TEXT = "Green Deployment"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ deployment_text }}</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-color: {{ background_color }};
            font-family: Arial, sans-serif;
        }
        .container {
            text-align: center;
        }
        h1 {
            color: white;
            font-size: 4rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>{{ deployment_text }}</h1>
    </div>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(
        HTML_TEMPLATE,
        background_color=BACKGROUND_COLOR,
        deployment_text=DEPLOYMENT_TEXT
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
