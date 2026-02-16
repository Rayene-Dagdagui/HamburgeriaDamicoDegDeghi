import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class FlaskServiceService {
  private apiUrl = 'http://localhost:5000/api';

  constructor(private http: HttpClient) { }

  // ============ ORDINI ============

  getAllOrders(): Observable<any> {
    return this.http.get(`${this.apiUrl}/orders`);
  }

  getOrdersByStatus(status: string): Observable<any> {
    return this.http.get(`${this.apiUrl}/orders?status=${status}`);
  }

  getOrder(orderId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/orders/${orderId}`);
  }

  updateOrderStatus(orderId: number, status: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/orders/${orderId}/status`, { status });
  }

  // ============ PRODOTTI ============

  getAllProducts(): Observable<any> {
    return this.http.get(`${this.apiUrl}/products`);
  }

  getCategories(): Observable<any> {
    return this.http.get(`${this.apiUrl}/categories`);
  }

  getProductsByCategory(category: string): Observable<any> {
    return this.http.get(`${this.apiUrl}/products/category/${category}`);
  }

  getProduct(productId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/products/${productId}`);
  }

  createProduct(product: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/products`, product);
  }

  updateProduct(productId: number, product: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/products/${productId}`, product);
  }

  deleteProduct(productId: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/products/${productId}`);
  }
}
