
# export local docker image via singularity
# whitebox:latest - local docker image. Note `:latest` is required
# whitebox.sif is the singularity image we can use in a remote machine

# sudo singularity build whitebox.sif docker-daemon://whitebox:latest
singularity exec \
  --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/  \
  --bind /g/data/ge3/sudipta/jobs/cogs/80m_albers/:/mount_dir/ \
  /g/data/ge3/sudipta/jobs/docker/whitebox.sif \
  /whitebox-tools/target/release/whitebox_tools \
  -r=MaxElevationDeviation -v --dem=/mount_dir/demh1sv1_0_80m_albers.tif \
  --out_mag=/mount_dir/dem_mag0.tif \
  --out_scale=/mount_dir/dem_scale0.tif \
  --min_scale=3 --max_scale=99 --step=1
