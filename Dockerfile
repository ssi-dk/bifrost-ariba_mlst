# This is intended to run in Github Actions
# Arg can be set to dev for testing purposes
ARG BUILD_ENV="prod"
ARG NAME="bifrost_ariba_mlst"
ARG CODE_VERSION="unspecified"
ARG RESOURCE_VERSION="200820"
ARG MAINTAINER="kimn@ssi.dk"

# For dev build include testing modules via pytest done on github and in development.
# Watchdog is included for docker development (intended method) and should preform auto testing 
# while working on *.py files
#
# Test data is in bifrost_run_launcher:dev
#- Source code (development):start------------------------------------------------------------------
FROM ssidk/bifrost_run_launcher:dev as build_dev
ONBUILD ARG NAME
ONBUILD COPY . /${NAME}
ONBUILD WORKDIR /${NAME}
ONBUILD RUN \
    sed -i'' 's/<code_version>/'"${CODE_VERSION}"'/g' ${NAME}/config.yaml; \
    sed -i'' 's/<resource_version>/'"${RESOURCE_VERSION}"'/g' ${NAME}/config.yaml; \
    pip install -r requirements.dev.txt;
#- Source code (development):end--------------------------------------------------------------------

#- Source code (productopm):start-------------------------------------------------------------------
FROM continuumio/miniconda3:4.7.10 as build_prod
ONBUILD ARG NAME
ONBUILD WORKDIR ${NAME}
ONBUILD COPY ${NAME} ${NAME}
ONBUILD COPY setup.py setup.py
ONBUILD COPY requirements.txt requirements.txt
ONBUILD RUN \
    sed -i'' 's/<code_version>/'"${CODE_VERSION}"'/g' ${NAME}/config.yaml; \
    sed -i'' 's/<resource_version>/'"${RESOURCE_VERSION}"'/g' ${NAME}/config.yaml; \
    ls; \
    pip install -r requirements.txt
#- Source code (productopm):end---------------------------------------------------------------------

#- Use development or production to and add info: start---------------------------------------------
FROM build_${BUILD_ENV}
ARG NAME
LABEL \
    name=${NAME} \
    description="Docker environment for ${NAME}" \
    code_version="${CODE_VERSION}" \
    resource_version="${RESOURCE_VERSION}" \
    environment="${BUILD_ENV}" \
    maintainer="${MAINTAINER}"
#- Use development or production to and add info: end---------------------------------------------

#- Tools to install:start---------------------------------------------------------------------------
RUN \
    conda install -yq -c conda-forge -c bioconda -c default snakemake-minimal==5.7.1; \
    apt-get update && apt-get install -y -qq --fix-missing \
        ariba=2.13.3+ds-1; \
    pip list;
#- Tools to install:end ----------------------------------------------------------------------------

#- Additional resources (files/DBs): start ---------------------------------------------------------
# adapters.fasta included with src
#- Additional resources (files/DBs): end -----------------------------------------------------------

#- Source code:start -------------------------------------------------------------------------------
WORKDIR ${NAME}
RUN \
    mkdir resources; \
    cd resources; \
    mkdir mlst; 
WORKDIR ${NAME}\resources\mlst
RUN \
    # NOTE: running this will generate a DB which is time dependant. Please use docker image for this DB
    ariba pubmlstget "Achromobacter spp." Achromobacter_spp_; \
    ariba pubmlstget "Acinetobacter baumannii#1" Acinetobacter_baumannii_1; \
    ariba pubmlstget "Acinetobacter baumannii#2" Acinetobacter_baumannii_2; \
    ariba pubmlstget "Aeromonas spp." Aeromonas_spp_; \
    ariba pubmlstget "Anaplasma phagocytophilum" Anaplasma_phagocytophilum; \
    ariba pubmlstget "Arcobacter spp." Arcobacter_spp_; \
    ariba pubmlstget "Aspergillus fumigatus" Aspergillus_fumigatus; \
    ariba pubmlstget "Bacillus cereus" Bacillus_cereus; \
    ariba pubmlstget "Bacillus licheniformis" Bacillus_licheniformis; \
    ariba pubmlstget "Bacillus subtilis" Bacillus_subtilis; \
    ariba pubmlstget "Bartonella bacilliformis" Bartonella_bacilliformis; \
    ariba pubmlstget "Bartonella henselae" Bartonella_henselae; \
    ariba pubmlstget "Bordetella spp." Bordetella_spp_; \
    ariba pubmlstget "Borrelia spp." Borrelia_spp_; \
    ariba pubmlstget "Brachyspira hampsonii" Brachyspira_hampsonii; \
    ariba pubmlstget "Brachyspira hyodysenteriae" Brachyspira_hyodysenteriae; \
    ariba pubmlstget "Brachyspira intermedia" Brachyspira_intermedia; \
    ariba pubmlstget "Brachyspira pilosicoli" Brachyspira_pilosicoli; \
    ariba pubmlstget "Brachyspira spp." Brachyspira_spp_; \
    ariba pubmlstget "Brucella spp." Brucella_spp_; \
    ariba pubmlstget "Burkholderia cepacia complex" Burkholderia_cepacia_complex; \
    ariba pubmlstget "Burkholderia pseudomallei" Burkholderia_pseudomallei; \
    ariba pubmlstget "Campylobacter concisus/curvus" Campylobacter_concisus_curvus; \
    ariba pubmlstget "Campylobacter fetus" Campylobacter_fetus; \
    ariba pubmlstget "Campylobacter helveticus" Campylobacter_helveticus; \
    ariba pubmlstget "Campylobacter hyointestinalis" Campylobacter_hyointestinalis; \
    ariba pubmlstget "Campylobacter insulaenigrae" Campylobacter_insulaenigrae; \
    ariba pubmlstget "Campylobacter jejuni" Campylobacter_jejuni; \
    ariba pubmlstget "Campylobacter lanienae" Campylobacter_lanienae; \
    ariba pubmlstget "Campylobacter lari" Campylobacter_lari; \
    ariba pubmlstget "Campylobacter sputorum" Campylobacter_sputorum; \
    ariba pubmlstget "Campylobacter upsaliensis" Campylobacter_upsaliensis; \
    ariba pubmlstget "Candida albicans" Candida_albicans; \
    ariba pubmlstget "Candida glabrata" Candida_glabrata; \
    ariba pubmlstget "Candida krusei" Candida_krusei; \
    ariba pubmlstget "Candida tropicalis" Candida_tropicalis; \
    ariba pubmlstget "Candidatus Liberibacter solanacearum" Candidatus_Liberibacter_solanacearum; \
    ariba pubmlstget "Carnobacterium maltaromaticum" Carnobacterium_maltaromaticum; \
    ariba pubmlstget "Chlamydiales spp." Chlamydiales_spp_; \
    ariba pubmlstget "Citrobacter freundii" Citrobacter_freundii; \
    ariba pubmlstget "Clonorchis sinensis" Clonorchis_sinensis; \
    ariba pubmlstget "Clostridium botulinum" Clostridium_botulinum; \
    ariba pubmlstget "Clostridioides difficile" Clostridioides_difficile; \
    ariba pubmlstget "Clostridium septicum" Clostridium_septicum; \
    ariba pubmlstget "Corynebacterium diphtheriae" Corynebacterium_diphtheriae; \
    ariba pubmlstget "Cronobacter spp." Cronobacter_spp_; \
    ariba pubmlstget "Dichelobacter nodosus" Dichelobacter_nodosus; \
    ariba pubmlstget "Edwardsiella spp." Edwardsiella_spp_; \
    ariba pubmlstget "Enterobacter cloacae" Enterobacter_cloacae; \
    ariba pubmlstget "Enterococcus faecalis" Enterococcus_faecalis; \
    ariba pubmlstget "Enterococcus faecium" Enterococcus_faecium; \
    ariba pubmlstget "Escherichia coli#1" Escherichia_coli_1; \
    ariba pubmlstget "Escherichia coli#2" Escherichia_coli_2; \
    ariba pubmlstget "Flavobacterium psychrophilum" Flavobacterium_psychrophilum; \
    ariba pubmlstget "Gallibacterium anatis" Gallibacterium_anatis; \
    ariba pubmlstget "Haemophilus influenzae" Haemophilus_influenzae; \
    ariba pubmlstget "Haemophilus parasuis" Haemophilus_parasuis; \
    ariba pubmlstget "Helicobacter cinaedi" Helicobacter_cinaedi; \
    ariba pubmlstget "Helicobacter pylori" Helicobacter_pylori; \
    ariba pubmlstget "Helicobacter suis" Helicobacter_suis; \
    ariba pubmlstget "Kingella kingae" Kingella_kingae; \
    ariba pubmlstget "Klebsiella aerogenes" Klebsiella_aerogenes; \
    ariba pubmlstget "Klebsiella oxytoca" Klebsiella_oxytoca; \
    ariba pubmlstget "Klebsiella pneumoniae" Klebsiella_pneumoniae; \
    ariba pubmlstget "Kudoa septempunctata" Kudoa_septempunctata; \
    ariba pubmlstget "Lactobacillus salivarius" Lactobacillus_salivarius; \
    ariba pubmlstget "Leptospira spp." Leptospira_spp_; \
    ariba pubmlstget "Leptospira spp.#2" Leptospira_spp__2; \
    ariba pubmlstget "Leptospira spp.#3" Leptospira_spp__3; \
    ariba pubmlstget "Listeria monocytogenes" Listeria_monocytogenes; \
    ariba pubmlstget "Macrococcus canis" Macrococcus_canis; \
    ariba pubmlstget "Macrococcus caseolyticus" Macrococcus_caseolyticus; \
    ariba pubmlstget "Mannheimia haemolytica" Mannheimia_haemolytica; \
    ariba pubmlstget "Melissococcus plutonius" Melissococcus_plutonius; \
    ariba pubmlstget "Moraxella catarrhalis" Moraxella_catarrhalis; \
    ariba pubmlstget "Mycobacteria spp." Mycobacteria_spp_; \
    ariba pubmlstget "Mycobacterium abscessus" Mycobacterium_abscessus; \
    ariba pubmlstget "Mycobacterium massiliense" Mycobacterium_massiliense; \
    ariba pubmlstget "Mycoplasma agalactiae" Mycoplasma_agalactiae; \
    ariba pubmlstget "Mycoplasma bovis" Mycoplasma_bovis; \
    ariba pubmlstget "Mycoplasma hyopneumoniae" Mycoplasma_hyopneumoniae; \
    ariba pubmlstget "Mycoplasma hyorhinis" Mycoplasma_hyorhinis; \
    ariba pubmlstget "Mycoplasma iowae" Mycoplasma_iowae; \
    ariba pubmlstget "Mycoplasma pneumoniae" Mycoplasma_pneumoniae; \
    ariba pubmlstget "Mycoplasma synoviae" Mycoplasma_synoviae; \
    ariba pubmlstget "Neisseria spp." Neisseria_spp_; \
    ariba pubmlstget "Orientia tsutsugamushi" Orientia_tsutsugamushi; \
    ariba pubmlstget "Ornithobacterium rhinotracheale" Ornithobacterium_rhinotracheale; \
    ariba pubmlstget "Paenibacillus larvae" Paenibacillus_larvae; \
    ariba pubmlstget "Pasteurella multocida#1" Pasteurella_multocida_1; \
    ariba pubmlstget "Pasteurella multocida#2" Pasteurella_multocida_2; \
    ariba pubmlstget "Pediococcus pentosaceus" Pediococcus_pentosaceus; \
    ariba pubmlstget "Photobacterium damselae" Photobacterium_damselae; \
    ariba pubmlstget "Piscirickettsia salmonis" Piscirickettsia_salmonis; \
    ariba pubmlstget "Porphyromonas gingivalis" Porphyromonas_gingivalis; \
    ariba pubmlstget "Propionibacterium acnes" Propionibacterium_acnes; \
    ariba pubmlstget "Pseudomonas aeruginosa" Pseudomonas_aeruginosa; \
    ariba pubmlstget "Pseudomonas fluorescens" Pseudomonas_fluorescens; \
    ariba pubmlstget "Pseudomonas putida" Pseudomonas_putida; \
    ariba pubmlstget "Rhodococcus spp." Rhodococcus_spp_; \
    ariba pubmlstget "Riemerella anatipestifer" Riemerella_anatipestifer; \
    ariba pubmlstget "Salmonella enterica" Salmonella_enterica; \
    ariba pubmlstget "Saprolegnia parasitica" Saprolegnia_parasitica; \
    ariba pubmlstget "Sinorhizobium spp." Sinorhizobium_spp_; \
    ariba pubmlstget "Staphylococcus aureus" Staphylococcus_aureus; \
    ariba pubmlstget "Staphylococcus epidermidis" Staphylococcus_epidermidis; \
    ariba pubmlstget "Staphylococcus haemolyticus" Staphylococcus_haemolyticus; \
    ariba pubmlstget "Staphylococcus hominis" Staphylococcus_hominis; \
    ariba pubmlstget "Staphylococcus lugdunensis" Staphylococcus_lugdunensis; \
    ariba pubmlstget "Staphylococcus pseudintermedius" Staphylococcus_pseudintermedius; \
    ariba pubmlstget "Stenotrophomonas maltophilia" Stenotrophomonas_maltophilia; \
    ariba pubmlstget "Streptococcus agalactiae" Streptococcus_agalactiae; \
    ariba pubmlstget "Streptococcus bovis/equinus complex (SBSEC)" Streptococcus_bovis_equinus_complex__SBSEC_; \
    ariba pubmlstget "Streptococcus canis" Streptococcus_canis; \
    ariba pubmlstget "Streptococcus dysgalactiae equisimilis" Streptococcus_dysgalactiae_equisimilis; \
    ariba pubmlstget "Streptococcus gallolyticus" Streptococcus_gallolyticus; \
    ariba pubmlstget "Streptococcus oralis" Streptococcus_oralis; \
    ariba pubmlstget "Streptococcus pneumoniae" Streptococcus_pneumoniae; \
    ariba pubmlstget "Streptococcus pyogenes" Streptococcus_pyogenes; \
    ariba pubmlstget "Streptococcus suis" Streptococcus_suis; \
    ariba pubmlstget "Streptococcus thermophilus" Streptococcus_thermophilus; \
    ariba pubmlstget "Streptococcus thermophilus#2" Streptococcus_thermophilus_2; \
    ariba pubmlstget "Streptococcus uberis" Streptococcus_uberis; \
    ariba pubmlstget "Streptococcus zooepidemicus" Streptococcus_zooepidemicus; \
    ariba pubmlstget "Streptomyces spp" Streptomyces_spp; \
    ariba pubmlstget "Taylorella spp." Taylorella_spp_; \
    ariba pubmlstget "Tenacibaculum spp." Tenacibaculum_spp_; \
    ariba pubmlstget "Treponema pallidum" Treponema_pallidum; \
    ariba pubmlstget "Trichomonas vaginalis" Trichomonas_vaginalis; \
    ariba pubmlstget "Ureaplasma spp." Ureaplasma_spp_; \
    ariba pubmlstget "Vibrio cholerae" Vibrio_cholerae; \
    ariba pubmlstget "Vibrio cholerae#2" Vibrio_cholerae_2; \
    ariba pubmlstget "Vibrio parahaemolyticus" Vibrio_parahaemolyticus; \
    ariba pubmlstget "Vibrio spp." Vibrio_spp_; \
    ariba pubmlstget "Vibrio tapetis" Vibrio_tapetis; \
    ariba pubmlstget "Vibrio vulnificus" Vibrio_vulnificus; \
    ariba pubmlstget "Wolbachia" Wolbachia; \
    ariba pubmlstget "Xylella fastidiosa" Xylella_fastidiosa; \
    ariba pubmlstget "Yersinia pseudotuberculosis" Yersinia_pseudotuberculosis; \
    ariba pubmlstget "Yersinia ruckeri" Yersinia_ruckeri; \
    ariba pubmlstget "Yersinia spp." Yersinia_spp_;
#- Source code:end ---------------------------------------------------------------------------------

#- Set up entry point:start ------------------------------------------------------------------------
ENTRYPOINT ["python3", "-m", "bifrost_ariba_mlst"]
CMD ["python3", "-m", "bifrost_ariba_mlst", "--help"]
#- Set up entry point:end --------------------------------------------------------------------------