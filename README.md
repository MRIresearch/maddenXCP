# maddenXCP
Customized version of xcp-engine version v1.2.3 to enable censoring of adjacent volumes

## Changes to xcp-engine

`${XCPEDIR}/utils/fd.R` main code has been commented out to prevent creation of the .../confound2/mc/${SUB}_${SES}_fd.1D file which is created from the 6 motion regressors provided by fmriprep.

'${XCPEDIR}/utils/generate_confmat.R' opportunistically create .../confound2/mc/${SUB}_${SES}_fd.1D as a copy of .../confound2/mc/${SUB}_${SES}_relRMS.1D which is created from the `framewise_displacement` field in the fMRIPREP confounds.tsv file.

## Workflow of maddenXCP

The python program `modifyConfounds.py` can be called to artificially flag volumes before and after an outlier volume that exceeds a framewise displacement threshold. The framewise displacement value for these neighboring timepoints is then replaced by an inflated value that will be subsequently picked up by xcpEngine as an outlier.
Please note that this functionality has only been created as an inelegant workaround to the above problem. Any functionality in xcpEngine that relies on accurate FD values will be compromised. This is likely to include some of the QCFC metrics that are calculated for each subject. A recommendation then is to run your denoising pipeline twice - once to derive the censored volumes using this custom version of xcpEngine and a second time with the proper stable version of xcpEngine to obtain gold standard outputs.

### Example
Using a framewise displacement threshold of 0.3mm, I intend to flag 2 preceding volumes to outlier volumes to be scrubbed and 1 subsequent volume.
I will replace the FD values of these volumes to be 0.5 mm so that the are definitely scrubbed by xcpEngine.

So in a toy example of 10 volumes with FD as follows [ 0.1 0.02 0.004 0.15 0.12 0.32 0.2 0.12 0.11 0.15]
We expect the 6th volume to be scrubbed and thus we want to also scrub volumes 4 and 5 and 7.
Thus after running this through `modifyConfounds.py` as follows

`modifyConfounds.py ${COUNFOUND_FILE} --confound_out=${BACKUP_NAME} --fd_thresh=0.3 --fd_replacement=0.5 --vols_before=2 --vols_after=1`

We get the following in our confounds file which can now be passed onto xcp for scrubbing:

`[ 0.1 0.02 0.004 0.5 0.5 0.32 0.5 0.12 0.11 0.15]`
