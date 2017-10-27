#!/usr/bin/env ruby

# TODO generate 1x5 zips

if __FILE__ == $0
  if ARGV.length != 2
    raise ArgumentError, "I need <source_dir> and <output_dir>"
  end

  source_dir, output_dir = ARGV

  # File name syntax
  # dataset-partitioning-validation-partnum-tratst.format
  # dataset-partitioning-validation-format.zip

  partitions = Dir[File.join(source_dir, "*")].map { |p| p.split("/").last }
  partitions_split = partitions.map { |p| p.split "-" }

  dataset_names = partitions_split.map(&:first).uniq!
  partitionings = partitions_split.map { |p| p[1] }.uniq!
  validations = partitions_split.map { |p| p[2] }.uniq!
  formats = {mulan: %w[arff xml], meka: %w[arff], libsvm: %w[svm], keel: %w[dat], mldr: %w[rds]}

  dataset_names.each do |dat|
    partitionings.each do |par|
      validations.each do |val|
        formats.each do |key, frm|
          frm_match = "(" + frm.join("|") + ")"
          file_match = /#{dat}-#{par}-#{val}-(\d+-)?(tra|tst)\.#{frm_match}$/
          selected = partitions.select { |f| f =~ file_match }
          archive_name = "#{dat}-#{par}-#{val}-#{key}.tar.gz"

          cmd = %[tar -acf #{File.join(output_dir, archive_name)} --directory="#{source_dir}" #{selected.join " "}]
          puts cmd
          system cmd
        end
      end
    end
  end
end
