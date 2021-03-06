#' Search for ZIP codes located within a given state
#'
#'
#' @param state_abb Two-digit code representing a U.S. state
#' @return tibble of all ZIP codes for each state code defined in state_abb
#' @examples
#' search_state('NJ')
#' search_state(c('NJ','NY','CT'))
#'
#' @export
search_state <- function(state_abb){
  # Ensure state abbreviation is capitalized for consistency
  state_abb <- toupper(state_abb)
  # Get matching ZIP codes for state
  state_zips <- zip_code_db %>%
    dplyr::filter(.data$state %in% state_abb)
  # Throw an error if nothing found
  if (nrow(state_zips) == 0) {
    stop(paste('No ZIP codes found for state:',state_abb))
  }
  # Print results to console
  if (length(state_abb) > 1) {
    base::cat(nrow(state_zips), 'ZIP codes found for states: ')
  } else if (length(state_abb) == 1) {
    base::cat(nrow(state_zips), 'ZIP codes found for state: ')
  }
  base::cat(paste0(shQuote(state_abb), collapse=", "),'\n')
  return(dplyr::as_tibble(state_zips))
}
#' Search ZIP codes for a county
#'
#'
#' @param state_abb Two-digit code for a U.S. state
#' @param county_name Name of a county within a U.S. state
#' @param ... if the parameter similar = TRUE, then send the parameter max.distance to the base function agrep. Default is 0.1.
#' @return tibble of all ZIP codes for given county name
#'
#' @examples
#' middlesex <- search_county('Middlesex','NJ')
#' alameda <- search_county('alameda','CA')
#' search_county("ST BERNARD","LA", similar = TRUE)$zipcode
#' @importFrom stringr str_detect
#' @importFrom rlang list2
#' @export
search_county <- function (county_name, state_abb, ...)
{
  dots <- rlang::list2(...)

  if (stringr::str_detect(state_abb, "^[:upper:]+$") == FALSE) {
    state_abb <- toupper(state_abb)
  }

  if("similar" %in% names(dots) && dots$similar == TRUE) {

    if("max.distance" %in% names(dots)) {
      max.distance <- dots$max.distance
    } else {
      max.distance <- 0.1
    }
    state_counties <- zip_code_db %>% dplyr::filter(.data$state == state_abb)
    county_name_proper <- agrep(county_name, state_counties$county,
                                ignore.case = TRUE, value = TRUE, max.distance = max.distance)

    county_zips <- zip_code_db %>% dplyr::filter(.data$state ==
                                                   state_abb & .data$county %in% county_name_proper)

  } else {
    if (stringr::str_detect(county_name, "^[:upper:]") == FALSE) {
      first_char <- toupper(substring(county_name, 0, 1))
      remainder <- substring(county_name, 2, nchar(county_name))
      county_name <- paste0(first_char, remainder)
    }
    county_name_proper <- paste(county_name, "County")
    county_zips <- zip_code_db %>% dplyr::filter(.data$state ==
                                                   state_abb & .data$county == county_name_proper)
  }

  if (nrow(county_zips) == 0) {
    stop(paste("No ZIP codes found for county:", county_name,
               ",", state_abb))
  }
  print(paste(nrow(county_zips), "ZIP codes found for",
              paste0(sapply(unique(county_name_proper), function(x) { paste(x, ",", state_abb) }), collapse = ' or ')))
  return(dplyr::as_tibble(county_zips))
}
#' Given a ZIP code, returns columns of metadata about that ZIP code
#'
#'
#' @param zip_code A 5-digit U.S. ZIP code or chracter vector with multiple ZIP codes
#' @return A tibble containing data for the ZIP code(s)
#'
#' @examples
#' reverse_zipcode('90210')
#' reverse_zipcode('08731')
#' reverse_zipcode(c('08734','08731'))
#' reverse_zipcode('07762')$county
#' reverse_zipcode('07762')$state
#' @export
reverse_zipcode <- function(zip_code) {
  # Convert to character so leading zeroes are preserved
  zip_code <- as.character(zip_code)
  # Get matching ZIP code record for
  zip_code_data <- zip_code_db %>%
    dplyr::filter(.data$zipcode %in% zip_code)
  # Throw an error if nothing found
  if (nrow(zip_code_data) == 0) {
    stop(paste('No data found for provided ZIP code',.data$zip_code,',',.data$state))
  }
  # Print results to console
  if (length(zip_code) > 1) {
    base::cat(nrow(zip_code_data), 'rows of data found for ZIP codes: ')
  } else if (length(zip_code) == 1) {
    base::cat(nrow(zip_code_data), 'row of data found for ZIP code: ')
  }
  base::cat(paste0(shQuote(zip_code), collapse=", "),'\n')
  return(dplyr::as_tibble(zip_code_data))
}
#' Search ZIP codes for a given city within a state
#'
#'
#' @param state_abb Two-digit code for a U.S. state
#' @param city_name Name of major city to search
#' @return tibble of all ZIP code data found for given city
#'
#' @examples
#' search_city('Spring Lake','NJ')
#' search_city('Chappaqua','NY')
#' @importFrom stringr str_detect
#' @export
search_city <- function(city_name, state_abb) {
  # Test if state name input is capitalized, capitalize if lowercase
  if (stringr::str_detect(state_abb, "^[:upper:]+$") == FALSE) {
    state_abb <- toupper(state_abb)
  }
  # Test if first letter of city name  input is capitalized, capitalize if input is lowercase
  if (stringr::str_detect(city_name, "^[:upper:]") == FALSE) {
    first_char <- toupper(substring(city_name,0,1))
    remainder <- substring(city_name,2,nchar(city_name))
    city_name <- paste0(first_char,remainder)
  }
  # Get matching ZIP codes for city
  city_zips <- zip_code_db %>% dplyr::filter(.data$state == state_abb & .data$major_city == city_name)
  # Throw an error if nothing found
  if (nrow(city_zips) == 0) {
    stop(paste('No ZIP codes found for city:',city_name,',', state_abb))
  }
  # Print number of ZIP codes found to console
  base::cat(paste(nrow(city_zips), 'ZIP codes found for', city_name,',', state_abb,'\n'))
  return(city_zips)
}
#' Search all ZIP codes located within a given timezone
#'
#' @param tz Timezone
#' @return tibble of all ZIP codes found for given timezone
#'
#' @examples
#' eastern <- search_tz('Eastern')
#' pacific <- search_tz('Mountain')
#' @export
search_tz <- function(tz) {
  # Get matching ZIP codes for timezone
  tz_zips <- zip_code_db %>% dplyr::filter(.data$timezone %in% tz)
  # Throw an error if nothing found
  if (nrow(tz_zips) == 0) {
    stop(paste('No ZIP codes found for timezone:',tz))
  }
  # Print number of ZIP codes found to console
  base::cat(paste(nrow(tz_zips), 'ZIP codes found for', tz,'timezone','\n'))
  return(dplyr::as_tibble(tz_zips))
}
#' Returns all ZIP codes found within a given FIPS code
#'
#' @param state_fips A U.S. FIPS code
#' @param county_fips A 1-3 digit county FIPS code (optional)
#' @return tibble of Census tracts and data from Census crosswalk file found for given ZIP code
#'
#' @examples
#' search_fips('34')
#' search_fips('34','03')
#' search_fips('34','3')
#' search_fips('36','003')
#' @importFrom rlang .data
#' @export
search_fips <- function(state_fips,county_fips) {
  # Get FIPS code data from tidycensus
  fips_data <- tidycensus::fips_codes
  # Separate routine if only state_fips code provided
  if (missing(county_fips)) {
    # Get matching FIPS data for provided state FIPS code
    fips_result <- fips_data %>% dplyr::filter(.data$state_code == state_fips)
    # Compare ZIP code database against provided state FIPS code, store matching ZIP code entries
    result <- zip_code_db %>% dplyr::filter(.data$state == fips_result$state[1])
    base::cat(nrow(result),'ZIP codes found for FIPS code',fips_result$state_code[1], paste0('(',fips_result$state[1],')'))
    return(result)
  } else {
    # Clean up county FIPS code input by adding leading zeroes to match FIPS code data if not present
    if (nchar(county_fips < 3)) {
      difference <- base::abs(nchar(county_fips) - 3)
      county_fips <- base::paste0(strrep('0', difference), county_fips)
    }
    # Get matching FIPS data for provided state & county FIPS code
    fips_result <- fips_data %>% dplyr::filter(.data$state_code == state_fips & .data$county_code == county_fips)
    # Compare ZIP code database against provided state FIPS code, store matching ZIP code entries
    result <- zip_code_db %>% dplyr::filter(.data$state == fips_result$state[1] & .data$county == fips_result$county[1])
    base::cat(nrow(result),'ZIP codes found for FIPS code',fips_result$state_code[1], paste0('(',fips_result$state[1],')'),fips_result$county_code[1], paste0('(',fips_result$county[1],')'))
    return(dplyr::as_tibble(result))
  }
}

#' Get all Census tracts within a given ZIP code
#'
#' @param zip_code A U.S. ZIP code
#' @return tibble of Census tracts and data from Census crosswalk file found for given ZIP code
#'
#' @examples
#' get_tracts('08731')
#' get_tracts('90210')
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
get_tracts <- function(zip_code) {
  # Validate input, raise error if input is not a 5-digit ZIP code
  if (nchar(zip_code) != 5) {
    stop("Invalid input detected. Please enter a 5-digit U.S. ZIP code.")
  }
  # Get tract data given ZCTA
  tracts <- zcta_crosswalk %>% dplyr::filter(.data$ZCTA5 == zip_code)
  if (nrow(tracts) == 0) {
    stop(paste("No Census tracts found for ZIP code", zip_code))
  }
  # Print number of tracts found to console
  base::cat(paste(nrow(tracts), 'Census tracts found for ZIP code', zip_code,'\n'))
  return(tracts)
}
#' Get all congressional districts for a given ZIP code
#'
#' @param zip_code A U.S. ZIP code
#' @return a named list of two-digit state code and two digit district code
#'
#' @examples
#' get_cd('08731')
#' get_cd('90210')
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
get_cd <- function(zip_code) {
  # Get state FIPS codes data from tidycensus library
  state_fips <- tidycensus::fips_codes
  # Match ZIP codes with congressional districts located within this ZIP
  matched_cds <- zip_to_cd %>% dplyr::filter(.data$ZIP == zip_code)
  # Break out the match from the ZIP to congressional district lookup into state FIPS code and congressional district codes
  district <- stringr::str_sub(matched_cds$CD,-2)
  state <- stringr::str_sub(matched_cds$CD, 1,2)
  # Bind the separated district and state codes together as a dataframe
  result <- data.frame(cbind(district,state))
  # Join the lookup result with tidycensus FIPS code data for more info
  joined <- result %>% dplyr::left_join(state_fips, by=c('state'='state_code'))
  output <- data.frame(joined$state.y[1],district) %>% dplyr::rename('state' = 'joined.state.y.1.')

  return(list(state_fips = joined$state.y[1], district = district))
}
#' Get all ZIP codes that fall within a given congressional district
#'
#' @param state_fips_code A two-digit U.S. FIPS code for a state
#' @param congressional_district A two digit number specifying a congressional district in a given
#' @return tibble of all congressional districts found for given ZIP code, including state code
#'
#' @examples
#' search_cd('34','03')
#' search_cd('36','05')
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
search_cd <- function(state_fips_code,congressional_district) {
  # Create code from state and congressional district to match lookup table
  cd_code <- base::paste0(state_fips_code,congressional_district)
  matched_zips <- zip_to_cd %>% dplyr::filter(.data$CD == cd_code)
  if (nrow(matched_zips) == 0) {
    stop(paste('No ZIP codes found for congressional district:', congressional_district))
  }
  # Print number of ZIP codes found to console
  base::cat(base::paste(nrow(matched_zips), 'ZIP codes found for', 'congressional district', congressional_district,'\n'))
  output <- matched_zips %>% dplyr::select(-.data$CD)
  output$state_fips <- state_fips_code
  output$congressional_district <- congressional_district
  return(dplyr::as_tibble(output))
}

#' Returns true if the given ZIP code is also a ZIP code tabulation area (ZCTA)
#'
#'
#' @param zip_code A 5-digit U.S. ZIP code
#' @return Boolean TRUE or FALSE based upon whether provided ZIP code is a ZCTA by testing whether it exists in the U.S. Census crosswalk data
#'
#' @examples
#' is_zcta('90210')
#' is_zcta('99999')
#' is_zcta('07762')
#' @export
is_zcta <- function(zip_code) {
  # Convert to character so leading zeroes are preserved
  zip_code <- as.character(zip_code)
  # Test if provided ZIP code exists within Census ZCTA crosswalk
  result <- zip_code %in% zcta_crosswalk$ZCTA5
  return(result)
}





