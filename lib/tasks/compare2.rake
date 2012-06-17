require 'yaml'
require 'active_support'

$unused = 0

def find_deprecations(h)
  h.each do |k,v|
    if not h[k].is_a?(Hash) then
      if `grep -ir "#{k}" app/*`.blank? then
        puts "#{k}: doesn't seem to be used."
        $unused += 1
      end
    else
      find_deprecations(h[k])
    end
  end
end

def remove_deprecations(orig_hash)
  new_hash = Hash.new
  orig_hash.each do |key,value|
    if not orig_hash[key].is_a?(Hash) then
      if `grep -ir "#{key}" app/*`.blank? then
        puts "#{key}: doesn't seem to be used."
        $unused += 1
      else
        new_hash[key] = value
      end
    else
      new_hash[key] = remove_deprecations(orig_hash[key])
    end
  end
  return new_hash
end

# this just copies translations from source into target, if they are not existing there
def merge(source,target)
  source.stringify_keys!
  target.stringify_keys!
  source.each do |key,value|
    if not value.is_a? Hash and not target[key] then
      puts "  #{key} not present in target. Copying"
      target[key] = "XXX " + source[key]
    elsif value.is_a? Hash and target[key] then
      target[key] = merge(value,target[key])
    end
  end
  return target
end

# this copies translations from source into target, if they are not existing there AND deletes all nodes from target not present in source
def clean(source,target)
  source.stringify_keys!
  target.stringify_keys!
  output = Hash.new
  target.each do |key,value|
    if not value.is_a? Hash and source[key]
      output[key] = value
    elsif value.is_a? Hash and source[key]
      output[key] = clean(source[key],value)
    else
      puts "  Not copying #{key} to output"
    end
  end
  return output
end

def compare_yaml_hash(cf1, cf2, context = [])
  cf1.each do |key, value|
    unless cf2.key?(key)
      if value.is_a?(Hash)
        format_hash(context, [key], value)
      else
        puts '{{ ' + context.join(' -> ') + ' }} ' + key + ': ' + value
      end
      next
    end
    if value.is_a?(Hash)
      compare_yaml_hash(value, cf2[key], (context << key))  
      next
    end
  end
  context.pop
end

def format_hash(absolute_context, relative_context = [], hash)
  hash.each do |k,v|
    if v.is_a?(Hash)
      format_hash(absolute_context, (relative_context << k), v)
      next
    else
      puts '{{ ' + absolute_context.join(' -> ') + ' -> ' + relative_context.join(' -> ') + ' }} ' + k.to_s + ': ' + v.to_s
    end
  end
end

def returning(value)
  yield(value)
  value
end

def convert_hash_to_ordered_hash_and_sort(object, deep = false)
# from http://seb.box.re/2010/1/15/deep-hash-ordering-with-ruby-1-8/
  if object.is_a?(Hash)
    # Hash is ordered in Ruby 1.9! 
    res = returning(RUBY_VERSION >= '1.9' ? Hash.new : ActiveSupport::OrderedHash.new) do |map|
      object.each {|k, v| map[k] = deep ? convert_hash_to_ordered_hash_and_sort(v, deep) : v }
    end
    return res.class[res.sort {|a, b| a[0].to_s <=> b[0].to_s } ]
  elsif deep && object.is_a?(Array)
    array = Array.new
    object.each_with_index {|v, i| array[i] = convert_hash_to_ordered_hash_and_sort(v, deep) }
    return array
  else
    return object
  end
end

namespace :translations do
  # usage: rake compare_locales['billgastro_gn.yml','billgastro_pl.yml']
  desc "Compare locales" 
  task :compare, :sourcefile, :transfile do |t, args|
    sourcefile = File.join(Rails.root,'config','locales',args[:sourcefile])
    source = YAML.load_file sourcefile
    sourcelang = source.keys.first
    source = source[sourcelang]
  
    transfile = File.join(Rails.root,'config','locales',args[:transfile])
    translation = YAML.load_file transfile
    translationlang = translation.keys.first
    translation = translation[translationlang]
  
    puts ''
    puts "============== ADD TO FILE #{ args[:transfile] } ============"
    puts ''
    compare_yaml_hash(source, translation, [translationlang])
  
    puts ''
    puts "=========== REMOVE FROM FILE #{ args[:transfile] } =========="
    puts ''
    compare_yaml_hash(translation, source, [translationlang])
  
  
  #   sourceordered = convert_hash_to_ordered_hash_and_sort(source, true)
  #   output_source = Hash.new
  #   output_source[sourcelang] = sourceordered
  # 
  #   translationordered = convert_hash_to_ordered_hash_and_sort(translation, true)
  #   output_translation = Hash.new
  #   output_translation[translationlang] = translationordered
  # 
  #   File.open(sourcefile,'w'){ |f| f.write output_source.to_yaml }
  #   File.open(transfile,'w'){ |f| f.write output_translation.to_yaml }
  
  end
  
  task :merge, :sourcefile, :transfile do |t,args|
    puts "Merging...\n"
    sourcefile = File.join(Rails.root,'config','locales',args[:sourcefile])
    source = YAML.load_file sourcefile
    sourcelang = source.keys.first
    source = source[sourcelang]
    
    transfile = File.join(Rails.root,'config','locales',args[:transfile])
    translation = YAML.load_file transfile
    translationlang = translation.keys.first
    translation = translation[translationlang]
    
    translation = merge(source,translation)
    
    output_translation = Hash.new
    output_translation[translationlang] = translation
    File.open(transfile,'w'){ |f| f.write output_translation.to_yaml }
  end
  
  task :clean, :sourcefile, :transfile do |t,args|
    puts "Cleaning...\n"
    sourcefile = File.join(Rails.root,'config','locales',args[:sourcefile])
    source = YAML.load_file sourcefile
    sourcelang = source.keys.first
    source = source[sourcelang]
    
    transfile = File.join(Rails.root,'config','locales',args[:transfile])
    translation = YAML.load_file transfile
    translationlang = translation.keys.first
    translation = translation[translationlang]
    
    translation = clean(source,translation)
    
    output_translation = Hash.new
    output_translation[translationlang] = translation
    File.open(transfile,'w'){ |f| f.write output_translation.to_yaml }
  end

  task :equalize, :sourcefile, :transfile do |t,args|
    puts "Equalizing ...\n"
    Rake::Task['translations:clean'].invoke(args[:sourcefile], args[:transfile])
    Rake::Task['translations:merge'].invoke(args[:sourcefile], args[:transfile])
  end
  
  task :order, :sourcefile do |t,args|
    puts "Sorting...\n"
    sourcefile = File.join(Rails.root,'config','locales',args[:sourcefile])
    source = YAML.load_file sourcefile
    sourcelang = source.keys.first
    source = source[sourcelang]
    sourceordered = convert_hash_to_ordered_hash_and_sort(source, true)
    output_source = Hash.new
    output_source[sourcelang] = sourceordered
    File.open(sourcefile,'w'){ |f| f.write output_source.to_yaml }
  end
  
  task :find_deprecations, :sourcefile do |t,args|
    puts "Finding deprecations...\n"
    sourcefile = File.join(Rails.root,'config','locales',args[:sourcefile])
    source = YAML.load_file sourcefile
    sourcelang = source.keys.first
    source = source[sourcelang]
    find_deprecations(source)
    puts "#{$unused} keys found."
  end
  
  task :remove_deprecations, :sourcefile do |t,args|
    puts "Removing deprecations...\n"
    sourcefile = File.join(Rails.root,'config','locales',args[:sourcefile])
    source = YAML.load_file sourcefile
    sourcelang = source.keys.first
    source = source[sourcelang]
    new_hash = remove_deprecations(source)
    output_source = Hash.new
    output_source[sourcelang] = new_hash
    File.open(sourcefile,'w'){ |f| f.write output_source.to_yaml }
    puts "#{$unused} keys found."
  end
  
  task :fix do
    base_path = File.join(Rails.root,'config','locales')
    base_name = "billgastro_XXX.yml" # i.e. the pattern name of the files
    langs = ["en","gn","ar","cn","el","en","es","fi","fr","hu","pl","it","ru","tr"]
    default_file = File.join(base_path,base_name.gsub('XXX',langs[0])) #i.e. the first file is the default file
    langs.each do |lang|
      current_file = File.join(base_path,base_name.gsub('XXX',lang))
      puts "Current File is: #{current_file}"
      if not File.exists? current_file then
        puts "Translation file doesn't exist, copying it..."
        `cp #{default_file} #{current_file}`
      else
        source = base_name.gsub('XXX',lang)
        target = base_name.gsub('XXX',langs[0])
        puts "Equalizing translations for #{source} and #{target}"
        Rake::Task['translations:equalize'].invoke(source, target)
        puts "Ordering translation #{target}"
        Rake::Task['translations:order'].invoke(target)
      end
    end
  end
end
