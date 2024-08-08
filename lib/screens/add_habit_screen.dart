import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedRingtone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onChanged: (value) {
                  name = value;
                },
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                onChanged: (value) {
                  description = value;
                },
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              ListTile(
                title: const Text("Select Date"),
                subtitle: Text(_selectedDate == null
                    ? "No date chosen"
                    : "${_selectedDate!.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: const Text("Select Time"),
                subtitle: Text(_selectedTime == null
                    ? "No time chosen"
                    : _selectedTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              ListTile(
                title: const Text("Select Ringtone"),
                subtitle: Text(_selectedRingtone ?? "No ringtone chosen"),
                trailing: const Icon(Icons.music_note),
                onTap: _pickRingtone,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null &&
                      _selectedTime != null) {
                    final DateTime scheduledDateTime = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                    Provider.of<HabitProvider>(context, listen: false)
                        .addHabit(name, description, scheduledDateTime, _selectedRingtone);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickRingtone() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() {
        _selectedRingtone = result.files.single.name.replaceAll('.mp3', '');
      });
    }
  }
}
