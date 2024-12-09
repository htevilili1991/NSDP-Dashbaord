# CPI Dashboard

## Overview
The CPI (Consumer Price Index) Dashboard is an interactive web application developed using R and Shiny. This dashboard provides insights and trends related to the CPI data for Vanuatu. It allows users to explore quarterly and annual CPI changes, visualizing the data through various interactive charts.

### Key Features
- **Dynamic Data Filters**: Filter CPI data by year, quarter, and location.
- **Interactive Charts**: View quarterly and annual CPI changes with bar charts.
- **Tab-based Layout**: Easy navigation through different sections, including a detailed dashboard and resource information.

## Technologies Used
- **R**: The core programming language for building the app.
- **Shiny**: For creating interactive web applications.
- **bs4Dash**: For building the dashboard UI with Bootstrap 4.
- **Highcharter**: For creating interactive charts and visualizations.
- **rsconnect**: For deploying the Shiny app to shinyapps.io or other servers.

## Setup & Installation

### Prerequisites
- R (version 4.0 or later)
- RStudio (optional but recommended)
- Internet connection to install R packages

### Installing Dependencies
Install the necessary R packages by running the following command in your R console:

```r
install.packages(c("rsconnect", "shiny", "bs4Dash", "highcharter", "dplyr", "DBI", "RSQLite"))
