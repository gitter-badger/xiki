# /, so show items and diffs...

if args == []
  # Narrow down to modified buffer only
  buffers = $el.buffer_list.to_a.
    select{|b| $el.buffer_modified_p(b)}.
    select{|b| $el.buffer_file_name(b)}

  if (buffers.size == 0)
    return "- No files unsaved!\n"
  end

  txt = ""

  buffers.each do |b|
    path = $el.buffer_file_name(b)
    $el.with(:save_excursion) do
      $el.set_buffer b

      diffs = DiffLog.save_diffs :just_return=>1

      if ! diffs
        diffs = "    : File no longer exists?\n" if ! File.exists?(path)
        diffs ||= "    : no changes\n"
      end
      diffs = diffs.sub(/^.+\n.+\n/, '').gsub /^  /, ''

      txt << "=#{path}\n"
      txt << diffs

    end
  end

  at_top = "+ quit anyway\n+ save all"
  txt = "#{at_top}\n#{txt}\n"

  return txt
end

# /quit anyway, so just exit...

if args == ["quit anyway"]
  $el.kill_emacs
  return ""
end

# /save all, so save all...

Buffers.list.map do |b|
  next if ! $el.buffer_file_name(b) || ! $el.buffer_modified_p(b)
  $el.with(:save_excursion) do
    $el.set_buffer b
    DiffLog.save
  end
end

"<! saved"

