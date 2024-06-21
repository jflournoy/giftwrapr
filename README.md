
# giftwrapr

The `giftwrapr` package provides tools to generate Dockerfiles and docker-compose files for R projects. It detects the packages used in your project and ensures that the correct versions are installed in a Docker container, facilitating easy replication of your environment.

## Installation

To install `giftwrapr`, you can use the following commands:

```r
# Install the package from your local repository
devtools::install_github("[[username]]/giftwrapr")
```

## Usage

(see "Both at Once" below for the easiest way)

### Generating a Dockerfile

The `generate_dockerfile` function generates a Dockerfile for your project. It detects the R packages used in your project and includes them in the Dockerfile, ensuring the specified versions are installed.

```r
library(giftwrapr)

# Generate Dockerfile for the project in the current directory
generate_dockerfile(project_dir = getwd(), use_latest_versions = FALSE, r_version = get_r_version(), platform = "linux/amd64")
```

#### Parameters:
- `project_dir`: The path to the project directory (default is the current working directory).
- `additional_cmds`: Additional Dockerfile commands to be added (optional).
- `use_latest_versions`: Logical indicating whether to use the latest versions of packages.
- `r_version`: The R version to be used in the Docker image (default is the current R version).
- `platform`: The platform to be used (default is "linux/amd64").

### Generating docker-compose.yml

The `generate_docker_compose` function generates a `docker-compose.yml` file for your project. It builds the Docker image from the Dockerfile and sets up the necessary configuration to run an RStudio server.

```r
library(giftwrapr)

# Generate docker-compose.yml for the project in the current directory
generate_docker_compose(project_dir = getwd(), service_name = "app", image_name = "my_image")
```

#### Parameters:
- `project_dir`: The path to the project directory (default is the current working directory).
- `service_name`: The name of the service (default is "app").
- `image_name`: The name of the Docker image (default is the project directory name).

### Both at Once

The `setup_docker_environment` function combines the functionality of `generate_dockerfile` and `generate_docker_compose`. It generates both the Dockerfile and the `docker-compose.yml` file for your project.

```r
library(giftwrapr)

# Setup Docker environment for the project in the current directory
setup_docker_environment(project_dir = getwd(), use_latest_versions = FALSE, r_version = get_r_version(), platform = "linux/amd64")
```

#### Parameters:
- `project_dir`: The path to the project directory (default is the current working directory).
- `use_latest_versions`: Logical indicating whether to use the latest versions of packages.
- `r_version`: The R version to be used in the Docker image (default is the current R version).
- `platform`: The platform to be used (default is "linux/amd64").
- `service_name`: The name of the service (default is the project directory name).

### Example Workflow

1. **Set up your project directory**: Ensure your R project is set up with all necessary scripts and data if applicable.

2. **Generate Dockerfile and docker-compose.yml**: Run the following commands to generate the necessary Docker configuration files.

```r
library(giftwrapr)

# Set up the Docker environment
setup_docker_environment(project_dir = "/path/to/your/project")
```

3. **Build and run the Docker container**: Navigate to your project directory and use Docker Compose to build and run the Docker container.

```bash
cd /path/to/your/project
docker-compose up --build
```

4. **Access RStudio**: Open your web browser and navigate to `http://localhost:8787`. You should see the RStudio server running with your project files and the specified package environment.

### Contribution

Feel free to contribute to this project by submitting issues or pull requests. Your contributions are always welcome!

### License

This project is licensed under the MIT License.
