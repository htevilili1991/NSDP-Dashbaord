# NSDP Dashboard

The **NSDP Dashboard** is a dynamic web-based application designed to provide an intuitive and insightful overview of the National Sustainable Development Plan (NSDP) indicators. It focuses on the analysis of households affected by various shocks, helping decision-makers and stakeholders identify key areas requiring attention. The dashboard was developed as part of an **internal staff dashboard competition** at the Vanuatu Bureau of Statistics.

## Features

### 1. **Interactive Data Visualizations**
- **KPI Boxes**: Provides key performance indicators (KPIs) for total households affected, the most common shock type, and the percentage of households affected by the top 3 shocks.
- **Charts**:
  - Bar charts show the distribution of households affected by shock types.
  - Pie charts illustrate the proportions of top 3 severe shocks.
- **Geographic Visualization**: Interactive Leaflet map highlights the regional breakdown of shocks by province.

### 2. **Data Filtering**
- **Province Filter**: Allows users to filter data by specific provinces or view aggregated data for all provinces.
- **Filterable Table**: An interactive data table with options for filtering and searching detailed data.

### 3. **Data Export**
- Export filtered data in multiple formats, including CSV, Excel, and PDF, for offline analysis.

### 4. **Help and Guidance**
- A dedicated “Help” button provides an interactive guide on how to use the dashboard features effectively.

## Installation

### Prerequisites
Ensure that the following are installed:
- **R** (version 4.0 or later)
- **RStudio** (optional, but recommended)
- Required R packages:
  - `shiny`
  - `bs4Dash`
  - `highcharter`
  - `DT`
  - `leaflet`
  - `sf`
  - `dplyr`
  - `readxl`
  - `jsonlite`
  - `tidyr`

### Setup Steps
1. Clone or download this repository.
2. Place the required data files in the `data/` directory:
   - `numberHHAffectedBy.csv`
   - `shockFigures.csv`
3. Open the `app.R` file in RStudio.
4. Install any missing packages using `install.packages()`.
5. Run the app using the command:
   ```R
   shiny::runApp()
   ```
6. Open your web browser to the displayed URL to access the dashboard.

## How to Use

### Navigation
- Use the **sidebar menu** to switch between the following tabs:
  - **Overview**: Displays KPIs, charts, and a geographic breakdown.
  - **Impact of Shocks on HH**: Provides a detailed filterable table of data.
- Use the **control bar** to filter data by province.

### Features
- **Charts and KPIs**: Hover over charts to view details, and observe KPIs for quick insights.
- **Interactive Map**: Click on markers to view data specific to a province.
- **Export Data**: Use the table’s export options to download filtered data.

### Help
- Click the “Help” button in the header for an interactive guide.

## Acknowledgments
This dashboard was developed as part of the **internal staff dashboard competition** organized by the Vanuatu Bureau of Statistics. It reflects our commitment to leveraging data and technology to support evidence-based decision-making.

## License
This project is licensed under the [MIT License](LICENSE).

---

