import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class FlaskServiceService {
  // baseUrl is relative so the dev server can proxy to the backend.
  // when Angular is hosted in GitHub Codespaces the browser's `localhost` refers
  // to the host machine, not the container. the proxy (see proxy.conf.json)
  // ensures requests to `/api` are forwarded to the Flask server on port 5000.
  private apiUrl = 'https://ideal-computing-machine-4jq7jjrj7jxg2q4w7-5000.app.github.dev/api';

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

  // ============ CATEGORIE ============

  getAllCategories(): Observable<any> {
    return this.http.get(`${this.apiUrl}/categories`);
  }

  getCategory(categoryId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/categories/${categoryId}`);
  }

  createCategory(category: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/categories`, category);
  }

  updateCategory(categoryId: number, category: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/categories/${categoryId}`, category);
  }

  deleteCategory(categoryId: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/categories/${categoryId}`);
  }

  // ============ PRODOTTI ============

  getAllProducts(): Observable<any> {
    return this.http.get(`${this.apiUrl}/products`);
  }

  getProductsByCategory(categoryId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/products/category/${categoryId}`);
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
