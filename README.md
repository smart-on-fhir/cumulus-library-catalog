# cumulus-library-catalog
Browsable hierarchies of pre-calculated counts for various coding systems. Part of the 
[SMART on FHIR Cumulus Project](https://smarthealthit.org/cumulus)

For more information, 
[browse the Cumulus Library documentation](https://docs.smarthealthit.org/cumulus/library).

## Installing

You can install this study with `pip install cumulus-library-catalog`

## Usage

As a prerequisite, you will need to have run the `core` study that ships with Cumulus Library, as well as the
[UMLS Study](https://github.com/smart-on-fhir/cumulus-library-umls)
to get information about various coding systems.

After this, you build this study the same way as any other Cumulus study, with
`cumulus-library build -t catalog`, along with any additional arguments about your target database.

## Citations

Bodenreider O. The Unified Medical Language System (UMLS): integrating biomedical terminology. Nucleic Acids Res. 2004 Jan 1;32(Database issue):D267-70. doi: 10.1093/nar/gkh061. PubMed PMID: 14681409; PubMed Central PMCID: PMC308795.