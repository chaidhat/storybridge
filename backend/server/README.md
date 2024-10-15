# Environment Variable Setup

    Make two files: .env.production and .env.development in the backend/ folder

## Usage

    .env.production environment variables will be used with npm run prod (for server production use)
    .env.development environment variables will be used in npm run dev (for local machine development)

## Sample File

    MYSQL_HOSTNAME=127.0.0.1
    MYSQL_PORT=3306
    MYSQL_USER=root
    MYSQL_PASS=pass
    MYSQL_DBNAME=my_db

    EXPRESS_PORT=3001

    # Note: these must end in a /

    # Path to files being processed (e.g files being compressed)
    TMP_PATH="/"
    # Path to all stored user content
    CONTENT_DATA_PATH="/"

    OPENAI_API_KEY=...

    STRIPE_API_KEY=...
    STRIPE_ENDPOINT_SECRET=...
