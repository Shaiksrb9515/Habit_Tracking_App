import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'habit_provider.dart';

class HabitList extends StatelessWidget {
  const HabitList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<HabitProvider>(context).habits,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final habits = snapshot.data!.docs;
        return ListView.builder(
          itemCount: habits.length,
          itemBuilder: (context, index) {
            var habit = habits[index];
            return ListTile(
              title: Text(habit['name']),
              subtitle: Text(habit['description']),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Provider.of<HabitProvider>(context, listen: false)
                      .deleteHabit(habit.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
