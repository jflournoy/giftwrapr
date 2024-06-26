# giftwrapr 🎁

The `giftwrapr` package helps you wrap your R projects in a Docker container based on [rocker/tidyverse](https://hub.docker.com/r/rocker/tidyverse/) for distribution of extra-special easy-to-reproduce code (with a bow). It detects the packages used in your project and ensures that they are part of the Dockerfile for automatic installation. It detects your current version of these packages and R (at runtime) facilitating easy replication of your environment. See below for a very rudimentary introduction to why it might be cool, good, or fun to use Docker.

## Installation

To install `giftwrapr`, you can use the following commands:

``` r
# Install the package from your local repository
devtools::install_github("jflournoy/giftwrapr")
```

## Usage

### Example Workflow

1.  **Set up your project directory**: Ensure your R project is set up with all necessary scripts and data if applicable.

2.  **Generate Dockerfile and docker-compose.yml**: Run the following commands to generate the necessary Docker configuration files.

``` r
library(giftwrapr)

# Set up the Docker environment
setup_docker_environment(project_dir = "/path/to/your/project")
```

3. **Check** your Dockerfile! Especially check that it's installing packages from the correct location. If you need to install packages from github, make sure to change the appropriate `remotes::install_version` lines. For this project, for example, I deleted autogenerated line in the Dockerfile that attempts to install this package, which is not on CRAN.

4.  **Build and run the Docker container**: Navigate to your project directory and use Docker Compose to build and run the Docker container.

``` bash
cd /path/to/your/project
docker-compose up --build
```

5.  **Access RStudio**: Open your web browser and navigate to `http://localhost:8787`. You should see the RStudio server running with your project files and the specified package environment.

### Generating a Dockerfile

The `generate_dockerfile` function generates a Dockerfile for your project. It detects the R packages used in your project and includes them in the Dockerfile, ensuring the specified versions are installed.

``` r
library(giftwrapr)

# Generate Dockerfile for the project in the current directory
generate_dockerfile()
```

#### Parameters:

-   `project_dir`: The path to the project directory (default is the current working directory).
-   `additional_cmds`: Additional Dockerfile commands to be added (optional).
-   `use_latest_versions`: Logical indicating whether to use the latest versions of packages.
-   `r_version`: The R version to be used in the Docker image (default is the current R version).
-   `platform`: The platform to be used (default is "linux/amd64").

### Generating docker-compose.yml

The `generate_docker_compose` function generates a `docker-compose.yml` file for your project. It builds the Docker image from the Dockerfile and sets up the necessary configuration to run an RStudio server.

``` r
library(giftwrapr)

# Generate docker-compose.yml for the project in the current directory
generate_docker_compose()
```

#### Parameters:

-   `project_dir`: The path to the project directory (default is the current working directory).
-   `service_name`: The name of the service (default is "app").
-   `image_name`: The name of the Docker image (default is the project directory name).

### Both at Once

The `setup_docker_environment` function combines the functionality of `generate_dockerfile` and `generate_docker_compose`. It generates both the Dockerfile and the `docker-compose.yml` file for your project.

``` r
library(giftwrapr)

# Setup Docker environment for the project in the current directory
setup_docker_environment()
```

#### Parameters:

-   `project_dir`: The path to the project directory (default is the current working directory).
-   `use_latest_versions`: Logical indicating whether to use the latest versions of packages.
-   `r_version`: The R version to be used in the Docker image (default is the current R version).
-   `platform`: The platform to be used (default is "linux/amd64").
-   `service_name`: The name of the service (default is the project directory name).

### Contribution

Feel free to contribute to this project by submitting issues or pull requests.

### License

This project is licensed under the MIT License.

# ELI5 Docker

"It lets people run an analysis _you_ ran on their own computer, without making them installing everything you used&mdash;like a virtual desktop that includes the packages you need." &ndash;Carol, paraphrasing me better than I said it originally.

With the help of an LLM (which I dragged kicking to a reasonably good analogy):

Imagine you have a suitcase. In this suitcase, you pack everything you need for your trip: clothes, toiletries, gadgets, and even some snacks. No matter where you go, you just need to take this suitcase with you, and you'll have everything you need.

A Docker container is like that suitcase for software. Inside the Docker container, you pack everything the application needs to run: the code, libraries, settings, and any other dependencies.

Here’s what makes this suitcase (Docker container) special:

1. Isolates the Application: Just like your suitcase keeps all your belongings separate from the outside world, a Docker container keeps the application and its dependencies separate from the host system. This means the application inside the container won’t be affected by the differences or issues in the host system.
2. Simplifies Deployment: When you travel, you just pick up your packed suitcase and go. Similarly, with a Docker container, you can move the application to different computers or servers easily because everything it needs is already packed inside the container.
3. Enhances Efficiency: Instead of carrying each item individually, your suitcase organizes and compacts everything into one place. Docker containers do the same by sharing the host system’s resources, making them more efficient and quicker to start than full virtual machines, which need their own separate resources.
4. Ensures Consistency: Every time you open your suitcase, you find your belongings exactly as you packed them, no matter where you are. Similarly, a Docker container ensures that the application runs the same way everywhere. If it works on your computer inside the container, it will work the same way on any other computer or server using the same container.

So, a Docker container is like a trusty suitcase for your software, keeping everything it needs in one place, making it easy to move, efficient to use, and consistent no matter where you go.

# Roadmap

- [ ] Specify package install sources and versions
- [ ] Specify base container
- [ ] Test build
- [ ] Remote build and deployment
- [ ] Test reproducibility of wraped scripts
