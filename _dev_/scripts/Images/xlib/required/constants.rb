# encoding: UTF-8
# frozen_string_literal: true

FOLDER_IMAGES = File.join('./img')

DATA_SIZES = {
  huge:         {name: 'huge',        width: 4000,  height: 2000},
  extra_large:  {name: 'extra-large', width: 2560,  height: 1600},
  very_large:   {name: 'very-large',  width: 1680,  height: 1050},
  large:        {name: 'large',       width: 1080,  height: 680},
  bigger:       {name: 'bigger',      width: 500,   height: 500},
  big:          {name: 'big',         width: 250,   height: 250},
  regular:      {name: 'regular',     width: 100,   height: 100},
  small:        {name:'small',        width: 32,    height: 32},
  very_small:   {name: 'very-small',  width: 20,    height: 20},
}
# Comme une liste (pour être sûr du classement), celle qui servira
# à savoir les tailles qui doivent être faites.
DATA_SIZES_ARRAY = DATA_SIZES.collect{|ids, ds| ds.merge(id: ids)}.sort_by{|ds| ds[:width]}.reverse
