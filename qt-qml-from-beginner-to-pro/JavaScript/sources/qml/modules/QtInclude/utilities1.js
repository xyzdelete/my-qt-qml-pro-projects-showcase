// .import "utilities2.js" as Utilities2
Qt.include("utilities2.js")

function greeting()
{
  print("Hello there from external JS file: utilities1.js")
}

function combineAges(age1, age2) {
  return Utilities2.add(age1, age2)
}