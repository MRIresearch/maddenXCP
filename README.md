# maddenXCP
Customized version of **xcpEngine version v1.2.3** to enable censoring of adjacent volumes

## Using maddenXCP
This repository can be cloned to your local disk and then in the `./build` directory, the script `buildscript.sh` can be edited to create a docker image which can be converted to a singularity image with the command `singularity build $SINGNAME docker://$DOCKERURI`. You will have to push the docker image to **Docker Hub** to build it in singularity unless you create a local registry for managing your images.

A version of this docker image has been created which you can also download and use on your cluster without having to go through the build step above. It is called `aacazxnat/xcpengine-madden:1.0`

You can build a singularity image called `xcpengine-madden.sif` as follows:
`singularity build xcpengine-madden.sif docker://aacazxnat/xcpengine-madden:1.0`

## Changes to xcp-engine

`${XCPEDIR}/utils/fd.R` main code has been commented out to prevent creation of the `.../confound2/mc/${SUB}_${SES}_fd.1D` file which is created from the 6 motion regressors provided by fmriprep.

`${XCPEDIR}/utils/generate_confmat.R` opportunistically create `.../confound2/mc/${SUB}_${SES}_fd.1D` as a copy of `.../confound2/mc/${SUB}_${SES}_relRMS.1D` which is created from the `framewise_displacement` field in the fMRIPREP confounds.tsv file.

## Workflow of maddenXCP

The python program `modifyConfounds.py` can be called to artificially flag volumes before and after an outlier volume that exceeds a Framewise Displacement (FD) threshold. 

The framewise displacement value for these neighboring timepoints is then replaced by an inflated value that will be subsequently picked up by **xcpEngine** as an outlier.

Please note that this functionality has only been created as an inelegant workaround to the above problem. Any functionality in **xcpEngine** that relies on accurate FD values will be compromised. This is likely to include some of the QCFC metrics that are calculated for each subject. A recommendation then is to run your denoising pipeline twice. The first time to derive the censored volumes using this custom version of xcpEngine and then a second time with the proper stable version of xcpEngine to obtain gold standard outputs for some of the quality metrics that rely on accurate Framewise Displacement.

### Example
Using a framewise displacement threshold of `0.3mm`, I intend to flag 2 preceding volumes to outlier volumes to be scrubbed and 1 subsequent volume.
I will replace the FD values of these volumes to be `0.5 mm` so that the are definitely scrubbed by xcpEngine.

So in a toy example of 10 volumes with FD as follows `[ 0.1 0.02 0.004 0.15 0.12 0.32 0.2 0.12 0.11 0.15]`
We expect the 6th volume to be scrubbed and thus we want to also scrub volumes 4 and 5 and 7.
Thus after running this through `modifyConfounds.py` as follows

`modifyConfounds.py ${CONFOUND_FILE} --confound_out=${BACKUP_NAME} --fd_thresh=0.3 --fd_replacement=0.5 --vols_before=2 --vols_after=1`

We get the following in our confounds file which can now be passed onto xcp for scrubbing:

`[ 0.1 0.02 0.004 0.5 0.5 0.32 0.5 0.12 0.11 0.15]`

## Script Example
The script `runxcp.sh` provides an example of how one might use `modifyConfounds.py` and the custom version of **xcpEngine** to accomplish the example describe above.
