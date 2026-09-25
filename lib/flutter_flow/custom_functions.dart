import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

double calculatePrice(
  double price,
  double quantity,
) {
  return quantity * price;
}

double calculateTotalCartValue(
  List<double> productsPrices,
  List<double> addOnPrices,
  List<int> productQuantity,
  List<int> addOnQuantity,
) {
// Products Price = index 1 of List<int> productQuantity * index 1 of  List<double> productsPrices
//  Add Ons Price = index 1 of List<int> addOnQuantity * List<double> addOnPrices
// Sum of Products Price and Add Ons Price
  double productsPrice = 0.0;
  for (int i = 0; i < productQuantity.length; i++) {
    productsPrice += productQuantity[i] * productsPrices[i];
  }

  // Calculate the total price of add-ons
  double addOnsPrice = 0.0;
  for (int i = 0; i < addOnQuantity.length; i++) {
    addOnsPrice += addOnQuantity[i] * addOnPrices[i];
  }

  // Calculate the total cart value
  double totalCartValue = productsPrice + addOnsPrice;

  return totalCartValue;
}

int cartItemQuantity(List<int>? cartQuantity) {
// Using the `reduce` method to sum up all the elements
  return (cartQuantity ?? [])
      .fold(0, (previousValue, element) => previousValue + element);
}

int? countOrderOrProductQuantity(
  List<String> productList,
  String? productName,
  bool getProductQuantity,
) {
  // Handle the case where the list is null or empty
  if (productList == null || productList.isEmpty) {
    return 0;
  }

  if (getProductQuantity) {
    // THIS ONE GETS THE PRODUCT QUANTITY
    // Count the number of occurences of the productName in the productList
    return productList.where((product) => product == productName).length;
  } else {
    // Create a map to count occurences of each product
    // THIS ONE RETURNS THE NUMBER OF ALL PRODUCTS
    final productCounts = <String, int>{};

    // Count occurrences of each product in the list
    for (var product in productList) {
      productCounts[product] = (productCounts[product] ?? 0) + 1;
    }

    // Sum up all the quantities
    return productCounts.values.reduce((a, b) => a + b);
  }
}

double decrementCartTotal(
  double price,
  double totalvalue,
) {
  return totalvalue - price;
}

int incrementCartProductQuantity(int lastquantity) {
  return lastquantity + 1;
}

List<String> generateListOfNames(
  String authUserName,
  String otherUserName,
) {
  return [authUserName, otherUserName];
}

List<DocumentReference> generateListOfUsers(
  DocumentReference authUser,
  DocumentReference otherUser,
) {
  return [authUser, otherUser];
}

String getOtherUserName(
  List<String> listOfNames,
  String authUserName,
) {
  return authUserName == listOfNames.first
      ? listOfNames.last
      : listOfNames.first;
}

DocumentReference getOtherUserRef(
  List<DocumentReference> listOfUserRef,
  DocumentReference authUserRef,
) {
  return authUserRef == listOfUserRef.first
      ? listOfUserRef.last
      : listOfUserRef.first;
}

double? incrementCartTotalValue(
  double price,
  double totalValue,
) {
  return totalValue + price;
}

String? plusdeliveryfee(int? totalprice) {
// total price plus delivery fee 50 pesos
  double deliveryFee = 50.0;
  double totalPrice = 1234; // Assume this is calculated elsewhere
  return (totalPrice + deliveryFee).toString();
}

double? priceSummary(List<double>? allPrices) {
  if (allPrices == null || allPrices.isEmpty) {
    return null;
  }
  double sum = 0.0;
  for (double price in allPrices) {
    sum += price;
  }
  return sum;
}

double getCartTotal(List<CartItemsRecord> cartList) {
  double total = 0;
  for (final item in cartList) {
    final price = (item.price as num?)?.toDouble() ?? 0;
    final quantity = (item.quantity as num?)?.toDouble() ?? 1;
    total += price * quantity;
  }
  return total;
}
