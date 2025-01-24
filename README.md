# TFM: Innovative Statistical Frameworks for Enhanced V(D)J Repertoire Analysis 
**By Joel Moro Borrego - MBDS - 2025**

## Abstract
Immune repertoire analysis is essential for understanding adaptive immune responses, yet reconstructing V(D)J sequences from whole transcriptome RNA-sequencing (WTA) data presents significant challenges due to the short-read nature of 3′ sequencing and platform-specific limitations. In this study, we developed and evaluated a robust computational framework to reconstruct T-cell and B-cell receptor sequences using TRUST4, alongside a custom pipeline to address barcode-to-index translation for BD Rhapsody data. Despite the flexibility and error-tolerant capabilities of the framework, limitations inherent to BD Rhapsody, including the prevalence of multiplets and the incompatibility of standard tools optimized for 10x Genomics, reduced the statistical power of V(D)J reconstruction. While approximately 12–15% of cells were reconstructed by TRUST4, only 3–7% of total cells in the input datasets were fully recovered after accounting for barcode complexities. 

We also compared BD Rhapsody's Sample Tag-based demultiplexing with genotype-based computational methods such as scSplit. The native BD pipeline demonstrated superior performance, attributable to its direct experimental barcoding approach, which outperformed scSplit's reliance on SNP inference from WTA data. Multiplets, likely stemming from technical errors during droplet encapsulation, further hindered data quality and highlight the need for improved experimental handling. 

Our results demonstrate that while WTA can serve as a viable source for immune repertoire reconstruction, the 3′ sequencing approach is inherently limited for this purpose, with 5′ sequencing presenting a more suitable alternative for capturing full receptor diversity. Despite these challenges, the workflows developed here successfully integrate immune receptor data with transcriptomic profiles, offering a foundation for future improvements in single-cell immune profiling. This study underscores the critical need for optimizing both experimental protocols and computational tools to maximize the potential of single-cell immune analyses, particularly in non-standard platforms like BD Rhapsody. 

 ## Github Organization

### Code:
Contains the code with explanation and how to run sections.

### Supplementary Figures:
Contains the supplementary figures that could not be included in the main text. Additionaly, contains the figures of the text.
