Faitesvoscomptes::Application.routes.draw do

  mount Adherent::Engine, at: "/adherent"
  

  devise_for :users, 
    :controllers => { :registrations => "devise_registrations",
                      :confirmations => "devise_confirmations"
                    }
  devise_scope :user do

    get "devise/sessions/bye"
    get 'devise/registrations/waitingconfirmation'
    root :to => "devise/sessions#new"
  end

  # les chemins pour les liens qui sont dans le bandeau en bas de chaque page
  get "bottom/credit"
  get "bottom/contact"
  get "bottom/apropos"
  get "bottom/manuals"

  concern :exportable do
    collection do
      get :produce_pdf
      get :deliver_pdf
      get :pdf_ready # demande au serveur si le fichier est prêt
    end
  end  
  

  ##### ----------------- namespace COMPTA -------------------------

  namespace :compta do
    
    resources :organisms do
      resources :periods do
        member do
          get 'change' # pour changer d'exercice
        end
      end
    end
    resources :books do
      resources :writings do
        concerns :exportable
        member do
          post :lock
        end
        collection do
          post :all_lock
        end
      end
    end
    
    resources :sheets do
      concerns :exportable
      collection do
        get :bilans
        get :resultats
        get :benevolats
        get :liasse
        get :values_ready
      end
    end
    
    resource :two_periods_balance , only: :show do
        concerns :exportable
    end
      
    resource :nomenclature
    resource :fec # pour le fichier des écriture comptable
    
    # intégré dans periods.
    resources :periods do
      
      resource :balance do
        concerns :exportable 
      end
      
      resource :analytical_balance
      
      
      
      resources :accounts 
      resource :listing, only: [:new, :show, :create] do
        concerns :exportable
      end
      resource :general_book do
        concerns :exportable
      end
      resource :general_ledger do
        concerns :exportable
      end

      resources :selections do
        member do
          post :lock
        end
      end
      
    end
   
    resources :accounts do
      resource :listing, only: :show do
        concerns :exportable
      end
    end

    
  end
  # fin du namespace COMPTA


  
  ##################### namespace ADMIN ##############################"
  namespace 'admin' do

    resources :clones, :only=>[:new, :create]

    #    resources :users do
    #      resources :rooms
    #    end

    resources :rooms, :only=>[:index, :show, :new, :create, :destroy] 
    
    resources :organisms do

      resources :masks
      resources :subscriptions
      resource :bridge
      resources :books
      resources :income_books
      resources :outcome_books
      
    
      resources :destinations
      resources :bank_accounts 
      resources :cashes 
      resources :periods do
        member do
          get 'change'
          get 'close'
          get 'prepared'    
        end
        
        resources :natures do
          collection do
            post 'reorder' # pour permettre le tri par javascript
          end
        end
        
      end
    end
    resources :periods do
      resources :natures 
      resources :accounts 
    end
  end  # FIN DE ADMIN
  
  ####### namespace Importer ###########################
  namespace 'importer' do
    
    resources :bank_accounts do
      resource :bels_importer
    end
  end
  

  ################################################################################# 

  # DEBUTde la zone public

  #  resources :users do
  #    resources :rooms
  #  end

  # TODO simplifier car on n'utilise que l'action show
  resources :rooms

  resources :transfers # on se passe maintenant de organism
  # et aussi de book car automatiquement en book OD

  resources :organisms , :only=> [:index, :show] do
    resources :periods, :only=> [:index, :show] do
      member do
        get 'change' # pour changer d'exercice
      end
      resources :natures, only: :index do
        concerns :exportable
      end
       
    end

    resources :check_deposits, :only=>:new # pour faire des remises de chèques
     
    
    resources :bank_accounts do
      resources :check_deposits
      
    end

  end
  

  resources :bank_accounts do
    resources :imported_bels do
      member do
        post 'write' # pour écrire une écriture à partir d'une importation de
        # relevé bancaire
      end
      collection do
        delete 'destroy_all' 
      end
      
    end
    resource :bels_importer
    resources :virtual_book_lines, only: :index  do
      concerns :exportable
    end
    resources :bank_extracts do
      collection do
        get 'lines_to_point' # affiche les lignes en attente de pointage
      end
      member do
        post 'lock'
      end
    end
  end

  # match ':controller/:action/:id/with_user/:user_id'
  resources :bank_extracts do
    resources :modallines, :only=>:create  
    resources :bank_extract_lines do
      
      collection do
        get 'pointage' # affiche la vue de pointage d'un extrait de compte
        
        post 'enregistrer' # enregistre les lignes pointées dans la base
      end
      
    end
  end
  
  get 'masks/:mask_id/writing_masks/new', :to=>'writing_masks#new', :as=>'new_mask_writing'

    
  resources :books do
    resources :writings
    resources(:in_out_writings) { concerns :exportable }
    resources :lines do
      member do
        post 'lock' # pour la requete ajax
      end
    end
    
  end
  # TODO limiter les actions à celles utilisées
  resources :subscriptions 

  
  # TODO lines n'est probablement plus utilisé
  
  resources :income_books do
    resources :lines
    resources :in_out_writings
  end
  resources :outcome_books do
    resources :lines
    resources :in_out_writings
  end
  resources :cashes, :only=> [:show] do
    
    resources :cash_controls do
      member do
        put 'lock'
      end
    end
    resources :cash_lines do
      concerns :exportable # pour les 3 actions permettant d'exporter un pdf en dalayed_job
    end
  end

  resources :transfers

 
  root :to => "devise/sessions#new"
  
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
