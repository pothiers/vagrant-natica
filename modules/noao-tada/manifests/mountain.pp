class tada::mountain (
  $mtncache    =  '/var/tada/mountain_cache',
  ) {
  include tada::mountain::install
  include tada::mountain::config
  include tada::mountain::service
}
