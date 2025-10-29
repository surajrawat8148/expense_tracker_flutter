part of 'expense.dart';

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 1;

  @override
  Expense read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return Expense(
      id: f[0] as String,
      title: f[1] as String,
      amount: (f[2] as num).toDouble(),
      categoryId: f[3] as String,
      date: f[4] as DateTime,
      synced: (f[5] as bool?) ?? false,
      updatedAt: f[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.synced)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }
}
