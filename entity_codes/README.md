# Geographic entity codes and classifications reference lists

One of the critical obstacles to international comparative data analysis is to
ensure that data is appropriately matched across sources, to this end the
project assigns each country a unique code to match across data sources.
Different data providers use different approaches to country naming and coding,
sometimes two sources from the same provider can have different approaches.

## Note and disclaimer on country terms, nomenclature and naming

Country codes and classifications are used within the Blavatnik Index of
Public Administration for purely analytical purposes, the inclusion or
non-inclusion of a country, territory or geographic entity does not indicate a
formal position by the Blavatnik School of Government or the University of
Oxford on the legal status of any country, state, territory or geographic
feature nor does it indicate an endorsement by the Blavatnik School of
Government or the University of Oxford of any claim of sovereignty over any
country, state, territory or geographic feature.

## Overview of the entity code reference list

The project uses the
[ISO 3166-1 alpha-3 standard](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)
as the basis for country codes. The alpha-3 codes are preferred as these tend
to have a higher degree of visual and linguistic association with the country
than the alpha-2 codes. The reference list is available at `entity_codes.csv`.

The processing and assignment of country codes within the source data is made
possible by the
[`{countrycode}`](https://vincentarelbundock.github.io/countrycode/#/) R
package which provides a comprehensive approach for programmatic assessment
and assignment of country codes.

The file `entity_codes.csv` acts as the main reference list used in project
outputs, this is derived from the ISO 3166-1 alpha-3 standard, it includes:

- 193 UN member states
- 56 codes officially assigned under the ISO 3166-1 alpha-3 standard
- 6 user assigned codes

## Adaptations to the ISO 3166-1 standard

Due to the varied coverage of countries, territories and other geographic
entities in the input data source some bespoke adaptations to the ISO 3166-1
standard have been implemented in our data processing.

https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3#Indeterminate_reservations
https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#User-assigned_code_elements
https://unicode.org/reports/tr35/#unicode_region_subtag_validity

### Kosovo (`XKK`)

Data for Kosovo is provided in several data sources, however as Kosovo is not
a member of the United Nations it does not have official recognition in the
ISO 3166-1 standard (which is derived from UN sources). Code `XK` is commonly
used by the IMF, European Commission, SWIFT, and the Unicode CLDR and others as
a 2-character code for Kosovo, it is also the provisionally assigned TLD for
Kosovo based web domains. While a degree of harmonisation has taken place in
regards an alpha-2 code, various three-character codes have been observed in
source datasets, including `KOS`, `XKK`, `XKS` and `XKX`.

The code `XKK` is listed in the Unicode Consortium's Common Locale Data
Repository (CLDR) and is used in the BIPA for consistency.

### Northern Cyprus (`XNC`)

Northern Cyprus is formally recognised only by Türkyie and does not appear in
any of the BIPA source datasets. It is included for ease of processing of
cartographic source data to produce output mapping.

### Republic Srpska (`XRS`)

The Republic Srpska is one of the two federal entities of Bosnia & Herzegovina.
As a sub-national entity it does not have a ISO 3166-1 code, the user-assigned
code of `XRS` has been included to represent the Republic Srpska for the ease
of processing BIPA source data.

The Republic Srpska is only included in one source dataset (the International
Survey of Revenue Administration, ISORA) in which data for the federal entity
of Bosnia & Herzegovina is also provided in this dataset. As these data both
relate to the functioning of sub-national governments it has been excluded
from the output data.

### State of Palestine - Gaza (`XPG`)

ISO 3166-1 includes an entity code for the State of Palestine (`PSE`).

The Varieties of Democracy (VDEM) dataset is the only source the provide data
separately for the West Bank and the Gaza Strip. As other data sources for
Palestine rely largely on data or assessments provided by or relating to
the Palestinian National Authority data for the West Bank has been coded with
`PSE`, while a user-assigned code of `XPG` has been included for the ease of
processing source data.

### Somalilad (`XSL`)

Somaliland is an unrecognised state. The Varieties of Democracy is the only
BIPA dataset that provides data separately for Somaliland and the rest of
Somalia (including Puntland). The user-assigned code of `XSL` has been
included to represent Somaliland for the ease of processing BIPA source data.

### Zanzibar (`EAZ`)

Zanzibar is a semi-autonomous region of Tanzania. The ISO 3166-1 alpha-3
standard maintains an indeterminate reservation of `EAZ` for Zanzibar. This
code has been included in the BIPA list of entities for ease of processing
source data.

The Varieties of Democracy dataset is the only source the provide data
separately for Tanzania and Zanzibar, the data for Tanzania has been used in
output data as this accounts for the vast majority of Tanzania's population
(~97%).

## Geographic region classification

To aid in the presentation and analysis of the Index results countries and
territories have been allocated to a set of geographic regions. There are many
different approaches for classifying countries into geographic regions, in
reviewing the geographic spread of countries included in the Index a bespoke
classification has been developed to ensure that each group is of suitable size
for comparisons.

The classification assigns countries and territories to one of six groups:

- Americas (22 countries included in the Index results)
- Asia and Pacific (19 countries included in the Index results)
- Eastern Europe (20 countries included in the Index results)
- Middle East, North Africa and Central Asia (MENCA, 14 countries included in
  the Index results)
- Sub-Saharan Africa (25 countries included in the Index results)
- Western Europe (16 countries included in the Index results)

The file `entity_georegions.csv` maps the entity codes defined in
`entity_codes.csv` to both the Blavatnik Index of Public Administration's
custom classification and the UN's standard geographic schema of regions
(continents) and sub-regions.

The classification is based on the regional groupings used by the IMF for
their periodic regional economic outlook reports, with some modification. A key
reason for selecting the IMF grouping over others as the basis for our
classification was its inclusion of a "Middle East and Central Asia" grouping
and an "Asia and Pacific" grouping. There are several definitions of which
countries comprise "the Middle East", however when using any of these results
the number of countries included in the Index results is less than 10, the IMF
combines the Middle East and North Africa with countries in "central Asia"
(itself a grouping that also has multiple definitions). There are only two
countries from Oceania included in the Index results (Australia and New
Zealand), therefore a grouping which includes these with Asian countries is
useful for analytical purposes.

The IMF's regional groupings have been adapted in the following ways:

- Türkiye is included in the IMF's Europe grouping, but for our classification
  has been included in our Middle East, North Africa and Central Asia (MENCA)
  grouping. As a transcontinental country Türkiye has significant economic,
  social and cultural relationships with both Europe and the Middle East. We
  have included Türkyie within the MENCA group to ensure the grouping has a
  suitable number of countries and to reflect that it is included in several
  other definitions of the Middle East.
- Pakistan is included in the IMF's Middle East and Central Asia grouping, but
  for our classification has been included in the Asia and Pacific grouping.
  As a result of the legacy of British colonial rule, aspects of Pakistan's
  administrative traditions are more similar to other countries in the Indian
  sub-continent (Bangladesh, India and Sri Lanka) than the post-communist
  states of central Asia, and while a Muslim majority nation Pakistan is not
  typically included in other definitions of the Middle East.
- The IMF's Europe grouping has been split into two halves to provide groupings
  that are of similar size to the other geographic regions in the
  classification, for simplicity these have been labelled as "Eastern" and
  "Western" Europe.  For the purposes of our grouping, we define Western
  Europe as: the group of countries that were members of the European Union
  prior to its 2004 enlargement round, the members of the European Free Trade
  Association and other European microstates. The remaining countries of
  Europe are included in our Eastern Europe grouping, of these only the
  Republic of Cyprus is not a post-Communist state and while geographically in
  Asia it is a member of the European Union and its administrative traditions
  are more closely associated with other European countries than those in the
  Middle East, North Africa and Central Asia grouping.

Formally the geographic regions are defined as such:

- *Americas*: countries and territories that are wholly or mainly west of 30º
  West and east of 140º West, and including the US states of Alaska and Hawaii.
- *Asia and Pacific*: the contiguous group of countries and territories of the
  Eurasian landmass that are south and east of Pakistan, China and Mongolia
  (inclusive of those countries); and, also including land masses and island
  countries/territories that are east of 70º East and west of 140º West,
  excluding the US states of Alaska and Hawaii.
- *Eastern Europe*: the contiguous group of countries and territories of the
  Eurasian landmass that are east of Poland, Czechia, Slovakia, Hungary and
  Slovenia (inclusive of those countries), that are west of 40º East, that are
  north or east of Türkyie and Greece (exclusive of those countries); and,
  also including the countries of Russia and Cyprus.
- *Middle East, North Africa and Central Asia*: the contiguous group of
  countries and territories of the Eurasia landmass that are west of China and
  Pakistan (exclusive of those countries), south of Russia (exclusive of
  Russia), south or east of Türkyie (inclusive of Türkyie); the island of
  Bahrain; the contiguous group of countries and territories of the African
  landmass that are wholly or mainly north of 20º North; and also including the
  countries of Mauritania and Sudan.
- *Sub-Saharan Africa*: the contiguous group of countries and territories of
  the African landmass that are wholly or mainly south of 20º North (excluding
  Mauritania and Sudan); and the island countries/territories south of 20º
  North, east of 30º West, and west of 70º East.
- *Western Europe*: the contiguous group of countries on the Eurasian landmass
  that are west and north of Germany, Austria and Italy (inclusive of those
  countries); the contiguous countries of the Scandinavian peninsula (Finland,
  Norway and Sweden); the island countries or territories west of 22º East and
  north of 35º North; and including the country of Greece.

