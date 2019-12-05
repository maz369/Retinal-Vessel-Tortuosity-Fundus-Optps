# Retinal-Vessel-Tortuosity-Analysis
This script is for quantification of retinal vessel tortuosity in fundus/OPTOS images. Several measures of tortuosity is calculated and saved in an excel file.
This measures include:
* VTI: vessel tortuosity index. (VTI = 0.1*(len_arch * sd * num_critical_pts * (mean_dm)) / len_cord).
* curvature: mean absolute curvature.
* DI: density index. Mean distance measure between inflection points, normalized by vessel length.
* DM: distance measure. Ratio of vessel length to its chord length.

Tortuosity measures are based on vessel centerline within a circumpapillary region centered on the optic nerve head (ONH). The user needs to select the center of ONH and its diameter. Also, the user can modify thresholds for vessel segmentation. Additionally, the user needs to select endpoints of each vessel for extracting the centerline and calculating its tortuosity.
Please see the user manual **Retinal Vessel Tortuosity.pdf** for further instruction.

![Untitled](https://user-images.githubusercontent.com/34323960/70208908-a16ec580-16e3-11ea-9708-e211aa171119.png)   ![12](https://user-images.githubusercontent.com/34323960/70208447-70da5c00-16e2-11ea-8fce-e7a578e42570.png)



# User manual
Please see the pdf file with the name **Retinal Vessel Tortuosity** for detail description on how to use this tool. Detail explanation of parameter setting, and result interpretation is also provided in this manual.


# Citation
1) Khansari, et al. "Method for quantitative assessment of retinal vessel tortuosity in optical coherence tomography angiography applied to sickle cell retinopathy." Biomedical optics express 8.8 (2017):3796-3806.
2) Khansari, et al. "Relationship between retinal vessel tortuosity and oxygenation in sickle cell retinopathy" IJRV (Springer Nature), DOI: 10.1186/s40942-019-0198-3


# License
This software has been released to promote research and education in the field of medical image analysis. Feel free to use and/or redistribute for any non-commercial application. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR LIABILITY, WHETHER IN AN ACTION OF ONTRACT, TORT OR, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR USINF OTHER DEALINGS IN THE SOFTWARE.
