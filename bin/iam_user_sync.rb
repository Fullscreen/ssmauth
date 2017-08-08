#!/usr/bin/env ruby

# usage takes list of IAM groups, and add/removes local users to sync

iam_groups = ARGV
DEBUG = false

def get_iam_users(groups)
  iam_users = []
    groups.each do |group|
      cmd = "aws iam get-group --group-name #{group} --query 'Users[*].[UserName]' --output text"
      output = %x[#{cmd}]
      iam_users << output.split("\n")
    end
  return iam_users.flatten.compact.collect(&:strip)
end

def get_local_users
  local_users = []
  cmd = "getent group sudo | cut -d : -f 4"
  output = %x[#{cmd}]
  local_users << (output.split(",") - ["ubuntu"])
  return local_users.flatten.compact.collect(&:strip)
end

def iam_user_ssh_key(username)
  cmd = "aws iam list-ssh-public-keys --user-name #{username} --query 'SSHPublicKeys[?Status==`Active`].SSHPublicKeyId' --output text"
  output = %x[#{cmd}]
  if ( output.to_s == ~/NoSuchEntity/ ) || (output.to_s.empty?)
    return "Error"
  else
    puts "User: #{username}\tKeySize:#{output.size}\tKey:#{output.to_s}" if DEBUG
    return output.to_s
  end
end

def add_local_user(username)
  puts "#{username} NOT on system, adding ...."
  cmd = "useradd -m -s /bin/bash -G sudo #{username}"
  output = %x[#{cmd}]
  return
end

def del_local_user(username)
  return if username =~ /ubuntu/
  puts "#{username} being removed..."
  cmd = "userdel -f #{username}"
  output = %x[#{cmd}]
  return
end

$iam_current_users = get_iam_users(iam_groups)
exit if $iam_current_users.size < 2
$complete_current_users = get_local_users
$local_current_users = $complete_current_users - ["ubuntu"]

# Add new users
$iam_current_users.each do |valid_iam_user|
  clean_iam_user = valid_iam_user.to_s.strip.downcase
  if not $local_current_users.include?(clean_iam_user)
    if not iam_user_ssh_key(clean_iam_user) == "Error"
      puts "#{clean_iam_user} NOT found in local" if DEBUG
      add_local_user(clean_iam_user)
    else
      puts "#{clean_iam_user} does not have a ssh key on file... Skipping" if DEBUG
      next
    end
  else
   next
  end
end

# Remove any local users not present in valid IAM groups
$local_current_users.each do |current_local_user|
  puts "Checking #{current_local_user}"  if DEBUG
  if not $iam_current_users.include?(current_local_user.to_s.strip)
    puts "#{current_local_user.to_s.strip} should not be here now... removing."
    del_local_user(current_local_user.to_s.strip)
  end
end
